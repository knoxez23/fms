<?php

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->user = User::factory()->create();
    $this->token = $this->user->createToken('test-token')->plainTextToken;
});

test('inventory actions create audit events and can be listed', function () {
    $create = $this->postJson('/api/v1/inventories', [
        'item_name' => 'Mineral Mix',
        'category' => 'Feed',
        'quantity' => 10,
        'unit' => 'kg',
        'min_stock' => 3,
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $create->assertStatus(201);
    $inventoryId = (string) $create->json('id');

    $update = $this->putJson("/api/v1/inventories/{$inventoryId}", [
        'quantity' => 5,
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);
    $update->assertStatus(200);

    $delete = $this->deleteJson("/api/v1/inventories/{$inventoryId}", [], [
        'Authorization' => "Bearer {$this->token}",
    ]);
    $delete->assertStatus(204);

    $events = $this->getJson('/api/v1/audit-events?limit=20', [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $events->assertStatus(200);
    $events->assertJsonFragment([
        'event_type' => 'inventory.created',
        'entity_type' => 'inventory',
        'entity_id' => $inventoryId,
    ]);
    $events->assertJsonFragment([
        'event_type' => 'inventory.updated',
        'entity_type' => 'inventory',
        'entity_id' => $inventoryId,
    ]);
    $events->assertJsonFragment([
        'event_type' => 'inventory.deleted',
        'entity_type' => 'inventory',
        'entity_id' => $inventoryId,
    ]);
});

test('task supports source event metadata and audits on create', function () {
    $response = $this->postJson('/api/v1/tasks', [
        'title' => 'Restock Layer Feed',
        'status' => 'pending',
        'source_event_type' => 'InventoryLowStock',
        'source_event_id' => 'inv-12',
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $response->assertStatus(201);
    $response->assertJsonFragment([
        'source_event_type' => 'InventoryLowStock',
        'source_event_id' => 'inv-12',
    ]);

    $this->assertDatabaseHas('tasks', [
        'user_id' => $this->user->id,
        'title' => 'Restock Layer Feed',
        'source_event_type' => 'InventoryLowStock',
        'source_event_id' => 'inv-12',
    ]);

    $this->assertDatabaseHas('audit_events', [
        'user_id' => $this->user->id,
        'event_type' => 'task.created',
        'entity_type' => 'task',
    ]);
});
