<?php

use App\Models\Task;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->user = User::factory()->create();
    $this->token = $this->user->createToken('task-sync-test')->plainTextToken;
    $this->headers = ['Authorization' => "Bearer {$this->token}"];
});

test('task create persists source event metadata for mobile sync', function () {
    $payload = [
        'client_uuid' => '286bf803-1d55-4ec2-b9ed-1ff69355ab3c',
        'title' => 'Schedule vaccination follow-up',
        'description' => 'Generated from production quality alert',
        'status' => 'pending',
        'priority' => 'high',
        'source_event_type' => 'production',
        'source_event_id' => 'animal:41:prod:7',
    ];

    $response = $this->postJson('/api/v1/tasks', $payload, $this->headers);

    $response->assertStatus(201)
        ->assertJsonFragment([
            'client_uuid' => $payload['client_uuid'],
            'title' => $payload['title'],
            'source_event_type' => $payload['source_event_type'],
            'source_event_id' => $payload['source_event_id'],
        ]);

    $taskId = $response->json('id');
    expect($taskId)->not()->toBeNull();

    $this->assertDatabaseHas('tasks', [
        'id' => $taskId,
        'user_id' => $this->user->id,
        'client_uuid' => $payload['client_uuid'],
        'source_event_type' => $payload['source_event_type'],
        'source_event_id' => $payload['source_event_id'],
    ]);
});

test('task create is idempotent by client_uuid per user', function () {
    $payload = [
        'client_uuid' => '8f8acee8-66fa-4607-bdd7-395afdc6bd5c',
        'title' => 'Check irrigation pump',
        'status' => 'pending',
        'priority' => 'medium',
    ];

    $first = $this->postJson('/api/v1/tasks', $payload, $this->headers);
    $first->assertStatus(201);

    $second = $this->postJson('/api/v1/tasks', $payload, $this->headers);
    $second->assertStatus(200);

    $this->assertDatabaseCount('tasks', 1);
    $this->assertDatabaseHas('tasks', [
        'user_id' => $this->user->id,
        'client_uuid' => $payload['client_uuid'],
        'title' => $payload['title'],
    ]);
});

test('task client_uuid may be reused by another user without leaking data', function () {
    $payload = [
        'client_uuid' => '7cb7b5fb-0d43-4345-b701-ad708b68ecbc',
        'title' => 'Apply fertilizer',
        'status' => 'pending',
    ];

    $this->postJson('/api/v1/tasks', $payload, $this->headers)
        ->assertStatus(201);

    $otherUser = User::factory()->create();
    Sanctum::actingAs($otherUser);
    $this->postJson('/api/v1/tasks', $payload)
        ->assertSuccessful();

    $this->assertDatabaseCount('tasks', 2);
    $this->assertDatabaseHas('tasks', [
        'user_id' => $this->user->id,
        'client_uuid' => $payload['client_uuid'],
    ]);
    $this->assertDatabaseHas('tasks', [
        'user_id' => $otherUser->id,
        'client_uuid' => $payload['client_uuid'],
    ]);
});

test('task update keeps source metadata and updates status for sync reconciliation', function () {
    $task = Task::create([
        'title' => 'Irrigate maize field',
        'status' => 'pending',
        'source_event_type' => 'feeding',
        'source_event_id' => 'feed:11',
        'user_id' => $this->user->id,
    ]);

    $response = $this->putJson("/api/v1/tasks/{$task->id}", [
        'status' => 'completed',
        'source_event_type' => 'feeding',
        'source_event_id' => 'feed:11',
    ], $this->headers);

    $response->assertStatus(200)
        ->assertJsonFragment([
            'id' => $task->id,
            'status' => 'completed',
            'source_event_type' => 'feeding',
            'source_event_id' => 'feed:11',
        ]);

    $this->assertDatabaseHas('tasks', [
        'id' => $task->id,
        'status' => 'completed',
        'source_event_type' => 'feeding',
        'source_event_id' => 'feed:11',
    ]);
});

test('task approval fields persist and can be approved by owner role', function () {
    $response = $this->postJson('/api/v1/tasks', [
        'client_uuid' => 'f50d041d-a8c1-4c2d-a77f-fbc8e5e99361',
        'title' => 'Approve pump repair payment',
        'status' => 'pending',
        'priority' => 'high',
        'completion_notes' => 'Worker replaced the damaged valve and restarted the pump.',
        'approval_required' => true,
    ], $this->headers);

    $response->assertStatus(201)
        ->assertJsonPath('approval_required', true)
        ->assertJsonPath('approval_status', 'pending')
        ->assertJsonPath('completion_notes', 'Worker replaced the damaged valve and restarted the pump.');

    $taskId = $response->json('id');

    $this->putJson("/api/v1/tasks/{$taskId}", [
        'approval_required' => true,
        'approval_status' => 'approved',
        'approval_comment' => 'Good work. Ready to close.',
    ], $this->headers)
        ->assertStatus(200)
        ->assertJsonPath('approval_status', 'approved')
        ->assertJsonPath('approval_comment', 'Good work. Ready to close.');

    $this->assertDatabaseHas('tasks', [
        'id' => $taskId,
        'approval_required' => true,
        'approval_status' => 'approved',
        'approved_by' => (string) $this->user->id,
        'completion_notes' => 'Worker replaced the damaged valve and restarted the pump.',
        'approval_comment' => 'Good work. Ready to close.',
    ]);
});

test('task delete returns 404 for missing id allowing client idempotent handling', function () {
    $task = Task::create([
        'title' => 'Clean shed',
        'status' => 'pending',
        'user_id' => $this->user->id,
    ]);

    $this->deleteJson("/api/v1/tasks/{$task->id}", [], $this->headers)
        ->assertStatus(204);

    $this->deleteJson("/api/v1/tasks/{$task->id}", [], $this->headers)
        ->assertStatus(404);
});
