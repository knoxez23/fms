<?php

use App\Models\Task;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->user = User::factory()->create();
    $this->token = $this->user->createToken('task-sync-test')->plainTextToken;
    $this->headers = ['Authorization' => "Bearer {$this->token}"];
});

test('task create persists source event metadata for mobile sync', function () {
    $payload = [
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
            'title' => $payload['title'],
            'source_event_type' => $payload['source_event_type'],
            'source_event_id' => $payload['source_event_id'],
        ]);

    $taskId = $response->json('id');
    expect($taskId)->not()->toBeNull();

    $this->assertDatabaseHas('tasks', [
        'id' => $taskId,
        'user_id' => $this->user->id,
        'source_event_type' => $payload['source_event_type'],
        'source_event_id' => $payload['source_event_id'],
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

