<?php

use App\Models\Animal;
use App\Models\Crop;
use App\Models\Inventory;
use App\Models\Sale;
use App\Models\Task;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

test('protected api routes require authentication', function () {
    $this->getJson('/api/v1/animals')->assertStatus(401);
    $this->getJson('/api/v1/crops')->assertStatus(401);
    $this->getJson('/api/v1/tasks')->assertStatus(401);
    $this->getJson('/api/v1/inventories')->assertStatus(401);
    $this->getJson('/api/v1/sales')->assertStatus(401);
    $this->getJson('/api/v1/feeding-schedules')->assertStatus(401);
    $this->getJson('/api/v1/feeding-logs')->assertStatus(401);
    $this->getJson('/api/v1/animal-weights')->assertStatus(401);
    $this->getJson('/api/v1/animal-health-records')->assertStatus(401);
    $this->getJson('/api/v1/animal-production-logs')->assertStatus(401);
    $this->getJson('/api/v1/audit-events')->assertStatus(401);
    $this->getJson('/api/v1/weather')->assertStatus(401);
    $this->getJson('/api/v1/user')->assertStatus(401);
});

test('user cannot access another users core resources', function () {
    $owner = User::factory()->create();
    $owner->createToken('owner-token')->plainTextToken;

    $otherUser = User::factory()->create();
    $otherToken = $otherUser->createToken('other-token')->plainTextToken;

    $animal = Animal::create([
        'name' => 'Owner Animal',
        'type' => 'cattle',
        'user_id' => $owner->id,
    ]);
    $crop = Crop::create([
        'name' => 'Owner Crop',
        'planted_date' => now()->toDateString(),
        'area' => 1.0,
        'status' => 'planted',
        'user_id' => $owner->id,
    ]);
    $task = Task::create([
        'title' => 'Owner Task',
        'status' => 'pending',
        'user_id' => $owner->id,
    ]);
    $inventory = Inventory::create([
        'item_name' => 'Owner Item',
        'category' => 'Input',
        'quantity' => 10,
        'unit' => 'kg',
        'user_id' => $owner->id,
        'is_synced' => true,
    ]);
    $sale = Sale::create([
        'product_name' => 'Owner Sale',
        'quantity' => 1,
        'price' => 100,
        'date' => now()->toDateString(),
        'user_id' => $owner->id,
    ]);

    $headers = ['Authorization' => "Bearer {$otherToken}"];

    $this->getJson("/api/v1/animals/{$animal->id}", $headers)->assertStatus(404);
    $this->getJson("/api/v1/crops/{$crop->id}", $headers)->assertStatus(404);
    $this->getJson("/api/v1/tasks/{$task->id}", $headers)->assertStatus(404);
    $this->getJson("/api/v1/inventories/{$inventory->id}", $headers)->assertStatus(404);
    $this->getJson("/api/v1/sales/{$sale->id}", $headers)->assertStatus(404);

    $this->putJson("/api/v1/animals/{$animal->id}", ['weight' => 200], $headers)->assertStatus(404);
    $this->putJson("/api/v1/crops/{$crop->id}", ['status' => 'growing'], $headers)->assertStatus(404);
    $this->putJson("/api/v1/tasks/{$task->id}", ['status' => 'completed'], $headers)->assertStatus(404);
    $this->putJson("/api/v1/inventories/{$inventory->id}", ['quantity' => 8], $headers)->assertStatus(404);
    $this->putJson("/api/v1/sales/{$sale->id}", ['price' => 90], $headers)->assertStatus(404);

    $this->deleteJson("/api/v1/animals/{$animal->id}", [], $headers)->assertStatus(404);
    $this->deleteJson("/api/v1/crops/{$crop->id}", [], $headers)->assertStatus(404);
    $this->deleteJson("/api/v1/tasks/{$task->id}", [], $headers)->assertStatus(404);
    $this->deleteJson("/api/v1/inventories/{$inventory->id}", [], $headers)->assertStatus(404);
    $this->deleteJson("/api/v1/sales/{$sale->id}", [], $headers)->assertStatus(404);

    $this->assertDatabaseHas('animals', [
        'id' => $animal->id,
        'user_id' => $owner->id,
    ]);
});
