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

test('core farm crud actions create descriptive audit events', function () {
    $animal = $this->postJson('/api/v1/animals', [
        'name' => 'Bella',
        'type' => 'Dairy Cow',
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);
    $animal->assertStatus(201);
    $animalId = (string) $animal->json('id');

    $this->putJson("/api/v1/animals/{$animalId}", [
        'health_status' => 'Healthy',
    ], [
        'Authorization' => "Bearer {$this->token}",
    ])->assertStatus(200);

    $crop = $this->postJson('/api/v1/crops', [
        'name' => 'Tomatoes',
        'planted_date' => now()->toDateString(),
        'area' => 1.5,
        'status' => 'Growing',
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);
    $crop->assertStatus(201);
    $cropId = (string) $crop->json('id');

    $this->putJson("/api/v1/crops/{$cropId}", [
        'status' => 'Harvest Ready',
    ], [
        'Authorization' => "Bearer {$this->token}",
    ])->assertStatus(200);

    $staff = $this->postJson('/api/v1/staff-members', [
        'name' => 'James',
        'role' => 'Farm Worker',
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);
    $staff->assertStatus(201);
    $staffId = (string) $staff->json('id');

    $this->putJson("/api/v1/staff-members/{$staffId}", [
        'role' => 'Supervisor',
    ], [
        'Authorization' => "Bearer {$this->token}",
    ])->assertStatus(200);

    $sale = $this->postJson('/api/v1/sales', [
        'product_name' => 'Milk',
        'quantity' => 20,
        'unit' => 'liters',
        'price' => 55,
        'total_amount' => 1100,
        'payment_status' => 'pending',
        'date' => now()->toDateString(),
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);
    $sale->assertStatus(201);
    $saleId = (string) $sale->json('id');

    $this->putJson("/api/v1/sales/{$saleId}", [
        'payment_status' => 'paid',
    ], [
        'Authorization' => "Bearer {$this->token}",
    ])->assertStatus(200);

    $events = $this->getJson('/api/v1/audit-events?limit=50', [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $events->assertStatus(200);
    $events->assertJsonFragment([
        'event_type' => 'animal.created',
        'entity_type' => 'animal',
        'entity_id' => $animalId,
    ]);
    $events->assertJsonFragment([
        'event_type' => 'crop.updated',
        'entity_type' => 'crop',
        'entity_id' => $cropId,
    ]);
    $events->assertJsonFragment([
        'event_type' => 'staff.updated',
        'entity_type' => 'staff_member',
        'entity_id' => $staffId,
    ]);
    $events->assertJsonFragment([
        'event_type' => 'sale.created',
        'entity_type' => 'sale',
        'entity_id' => $saleId,
    ]);
    $events->assertJsonPath('0.metadata.summary', fn ($value) => is_string($value));

    $this->deleteJson("/api/v1/sales/{$saleId}", [], [
        'Authorization' => "Bearer {$this->token}",
    ])->assertStatus(204);
    $this->deleteJson("/api/v1/staff-members/{$staffId}", [], [
        'Authorization' => "Bearer {$this->token}",
    ])->assertStatus(204);
    $this->deleteJson("/api/v1/crops/{$cropId}", [], [
        'Authorization' => "Bearer {$this->token}",
    ])->assertStatus(204);
    $this->deleteJson("/api/v1/animals/{$animalId}", [], [
        'Authorization' => "Bearer {$this->token}",
    ])->assertStatus(204);

    $this->assertDatabaseHas('audit_events', [
        'user_id' => $this->user->id,
        'event_type' => 'sale.deleted',
        'entity_type' => 'sale',
    ]);
    $this->assertDatabaseHas('audit_events', [
        'user_id' => $this->user->id,
        'event_type' => 'animal.deleted',
        'entity_type' => 'animal',
    ]);
});

test('animal care records create audit events across feeding health production and weight', function () {
    $animal = $this->postJson('/api/v1/animals', [
        'name' => 'Molly',
        'type' => 'Dairy Goat',
    ], [
        'Authorization' => "Bearer {$this->token}",
    ])->assertStatus(201);
    $animalId = (string) $animal->json('id');

    $schedule = $this->postJson('/api/v1/feeding-schedules', [
        'animal_id' => (int) $animalId,
        'feed_type' => 'Hay',
        'quantity' => 2,
        'unit' => 'kg',
        'time_of_day' => 'Morning',
        'frequency' => 'Daily',
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);
    $schedule->assertStatus(201);
    $scheduleId = (string) $schedule->json('id');

    $log = $this->postJson('/api/v1/feeding-logs', [
        'animal_id' => (int) $animalId,
        'schedule_id' => (int) $scheduleId,
        'feed_type' => 'Hay',
        'quantity' => 2,
        'unit' => 'kg',
        'fed_at' => now()->toIso8601String(),
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);
    $log->assertStatus(201);
    $logId = (string) $log->json('id');

    $health = $this->postJson('/api/v1/animal-health-records', [
        'animal_id' => (int) $animalId,
        'type' => 'Vaccination',
        'name' => 'FMD',
        'treated_at' => now()->toIso8601String(),
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);
    $health->assertStatus(201);
    $healthId = (string) $health->json('id');

    $production = $this->postJson('/api/v1/animal-production-logs', [
        'animal_id' => (int) $animalId,
        'type' => 'Milk',
        'quantity' => 4,
        'unit' => 'liters',
        'produced_at' => now()->toIso8601String(),
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);
    $production->assertStatus(201);
    $productionId = (string) $production->json('id');

    $weight = $this->postJson('/api/v1/animal-weights', [
        'animal_id' => (int) $animalId,
        'weight' => 42.5,
        'recorded_at' => now()->toIso8601String(),
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);
    $weight->assertStatus(201);
    $weightId = (string) $weight->json('id');

    $events = $this->getJson('/api/v1/audit-events?limit=50', [
        'Authorization' => "Bearer {$this->token}",
    ]);
    $events->assertStatus(200);
    $events->assertJsonFragment([
        'event_type' => 'feeding_schedule.created',
        'entity_type' => 'feeding_schedule',
        'entity_id' => $scheduleId,
    ]);
    $events->assertJsonFragment([
        'event_type' => 'feeding_log.created',
        'entity_type' => 'feeding_log',
        'entity_id' => $logId,
    ]);
    $events->assertJsonFragment([
        'event_type' => 'animal_health.created',
        'entity_type' => 'animal_health_record',
        'entity_id' => $healthId,
    ]);
    $events->assertJsonFragment([
        'event_type' => 'animal_production.created',
        'entity_type' => 'animal_production_log',
        'entity_id' => $productionId,
    ]);
    $events->assertJsonFragment([
        'event_type' => 'animal_weight.created',
        'entity_type' => 'animal_weight',
        'entity_id' => $weightId,
    ]);
});
