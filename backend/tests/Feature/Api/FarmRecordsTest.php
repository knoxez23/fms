<?php

use App\Models\Animal;
use App\Models\AnimalHealthRecord;
use App\Models\AnimalProductionLog;
use App\Models\AnimalWeight;
use App\Models\Crop;
use App\Models\FeedingLog;
use App\Models\FeedingSchedule;
use App\Models\Inventory;
use App\Models\Sale;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->user = User::factory()->create();
    $this->token = $this->user->createToken('test-token')->plainTextToken;

    $this->otherUser = User::factory()->create();
    $this->otherToken = $this->otherUser->createToken('other-token')->plainTextToken;
});

test('user can create and scope animals/crops/sales', function () {
    $animal = $this->postJson('/api/v1/animals', [
        'name' => 'Daisy',
        'type' => 'cattle',
        'weight' => 320,
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);
    $animal->assertStatus(201);

    $animalId = $animal->json('id');
    expect($animalId)->not()->toBeNull();

    $otherAnimal = Animal::create([
        'name' => 'Other Cow',
        'type' => 'cattle',
        'user_id' => $this->otherUser->id,
    ]);
    $this->getJson("/api/v1/animals/{$otherAnimal->id}", [
        'Authorization' => "Bearer {$this->token}",
    ])->assertStatus(404);

    $crop = $this->postJson('/api/v1/crops', [
        'name' => 'Maize',
        'planted_date' => now()->toDateString(),
        'area' => 1.5,
        'status' => 'planted',
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);
    $crop->assertStatus(201)->assertJsonFragment(['name' => 'Maize']);

    $sale = $this->postJson('/api/v1/sales', [
        'product_name' => 'Milk',
        'quantity' => 20,
        'unit' => 'liters',
        'price' => 50,
        'total_amount' => 1000,
        'customer_name' => 'Customer A',
        'sale_date' => now()->toDateString(),
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);
    $sale->assertStatus(201)->assertJsonFragment(['product_name' => 'Milk']);

    $this->assertDatabaseHas('animals', ['id' => $animalId, 'user_id' => $this->user->id]);
    $this->assertDatabaseHas('crops', ['name' => 'Maize', 'user_id' => $this->user->id]);
    $this->assertDatabaseHas('sales', ['product_name' => 'Milk', 'user_id' => $this->user->id]);
});

test('feeding endpoints enforce animal ownership', function () {
    $ownedAnimal = Animal::create([
        'name' => 'Owned',
        'type' => 'goat',
        'user_id' => $this->user->id,
    ]);
    $otherAnimal = Animal::create([
        'name' => 'Other',
        'type' => 'goat',
        'user_id' => $this->otherUser->id,
    ]);

    $createOwned = $this->postJson('/api/v1/feeding-schedules', [
        'animal_id' => $ownedAnimal->id,
        'feed_type' => 'Hay',
        'quantity' => 4,
        'unit' => 'kg',
        'time_of_day' => 'morning',
        'frequency' => 'daily',
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);
    $createOwned->assertStatus(201);

    $createOther = $this->postJson('/api/v1/feeding-schedules', [
        'animal_id' => $otherAnimal->id,
        'feed_type' => 'Hay',
        'quantity' => 4,
        'unit' => 'kg',
        'time_of_day' => 'morning',
        'frequency' => 'daily',
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);
    $createOther->assertStatus(404);

    $schedule = FeedingSchedule::create([
        'animal_id' => $ownedAnimal->id,
        'feed_type' => 'Pellets',
        'quantity' => 2,
        'unit' => 'kg',
        'time_of_day' => 'evening',
        'frequency' => 'daily',
    ]);

    FeedingLog::create([
        'animal_id' => $ownedAnimal->id,
        'schedule_id' => $schedule->id,
        'feed_type' => 'Pellets',
        'quantity' => 2,
        'unit' => 'kg',
        'fed_at' => now(),
    ]);
    FeedingLog::create([
        'animal_id' => $otherAnimal->id,
        'feed_type' => 'Pellets',
        'quantity' => 3,
        'unit' => 'kg',
        'fed_at' => now(),
    ]);

    $list = $this->getJson('/api/v1/feeding-logs', [
        'Authorization' => "Bearer {$this->token}",
    ]);
    $list->assertStatus(200)->assertJsonCount(1);
});

test('feeding log linked to inventory deducts stock and restores on delete', function () {
    $animal = Animal::create([
        'name' => 'Stock Cow',
        'type' => 'cattle',
        'user_id' => $this->user->id,
    ]);

    $inventory = Inventory::create([
        'item_name' => 'Maize Germ',
        'category' => 'Animal Feed',
        'quantity' => 25,
        'unit' => 'kg',
        'min_stock' => 2,
        'unit_price' => 80,
        'total_value' => 2000,
        'user_id' => $this->user->id,
        'is_synced' => true,
    ]);

    $headers = ['Authorization' => "Bearer {$this->token}"];

    $created = $this->postJson('/api/v1/feeding-logs', [
        'animal_id' => $animal->id,
        'inventory_id' => $inventory->id,
        'feed_type' => 'Maize Germ',
        'quantity' => 5,
        'unit' => 'kg',
        'fed_at' => now()->toIso8601String(),
    ], $headers);

    $created->assertStatus(201)
        ->assertJsonPath('inventory_id', $inventory->id);

    $this->assertDatabaseHas('inventories', [
        'id' => $inventory->id,
        'quantity' => 20,
        'total_value' => 1600,
    ]);

    $logId = (string) $created->json('id');
    $this->deleteJson("/api/v1/feeding-logs/{$logId}", [], $headers)
        ->assertStatus(204);

    $this->assertDatabaseHas('inventories', [
        'id' => $inventory->id,
        'quantity' => 25,
        'total_value' => 2000,
    ]);
});

test('feeding log rejects consumption beyond available inventory', function () {
    $animal = Animal::create([
        'name' => 'Calf',
        'type' => 'cattle',
        'user_id' => $this->user->id,
    ]);

    $inventory = Inventory::create([
        'item_name' => 'Starter Feed',
        'category' => 'Animal Feed',
        'quantity' => 3,
        'unit' => 'kg',
        'min_stock' => 1,
        'unit_price' => 60,
        'total_value' => 180,
        'user_id' => $this->user->id,
        'is_synced' => true,
    ]);

    $response = $this->postJson('/api/v1/feeding-logs', [
        'animal_id' => $animal->id,
        'inventory_id' => $inventory->id,
        'feed_type' => 'Starter Feed',
        'quantity' => 5,
        'unit' => 'kg',
        'fed_at' => now()->toIso8601String(),
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $response->assertStatus(422)
        ->assertJsonValidationErrors(['inventory_id']);

    $this->assertDatabaseHas('inventories', [
        'id' => $inventory->id,
        'quantity' => 3,
        'total_value' => 180,
    ]);
});

test('animal record endpoints enforce ownership and persist', function () {
    $ownedAnimal = Animal::create([
        'name' => 'Owned Sheep',
        'type' => 'sheep',
        'user_id' => $this->user->id,
    ]);
    $otherAnimal = Animal::create([
        'name' => 'Other Sheep',
        'type' => 'sheep',
        'user_id' => $this->otherUser->id,
    ]);

    $this->postJson('/api/v1/animal-weights', [
        'animal_id' => $ownedAnimal->id,
        'weight' => 45.5,
        'recorded_at' => now()->toDateString(),
    ], [
        'Authorization' => "Bearer {$this->token}",
    ])->assertStatus(201);

    $this->postJson('/api/v1/animal-health-records', [
        'animal_id' => $ownedAnimal->id,
        'type' => 'vaccine',
        'name' => 'PPR',
    ], [
        'Authorization' => "Bearer {$this->token}",
    ])->assertStatus(201);

    $this->postJson('/api/v1/animal-production-logs', [
        'animal_id' => $ownedAnimal->id,
        'type' => 'milk',
        'quantity' => 3.2,
        'unit' => 'liters',
    ], [
        'Authorization' => "Bearer {$this->token}",
    ])->assertStatus(201);

    $this->postJson('/api/v1/animal-weights', [
        'animal_id' => $otherAnimal->id,
        'weight' => 99,
    ], [
        'Authorization' => "Bearer {$this->token}",
    ])->assertStatus(404);

    $this->assertDatabaseHas('animal_weights', [
        'animal_id' => $ownedAnimal->id,
        'user_id' => $this->user->id,
    ]);
    $this->assertDatabaseHas('animal_health_records', [
        'animal_id' => $ownedAnimal->id,
        'user_id' => $this->user->id,
        'name' => 'PPR',
    ]);
    $this->assertDatabaseHas('animal_production_logs', [
        'animal_id' => $ownedAnimal->id,
        'user_id' => $this->user->id,
        'type' => 'milk',
    ]);
});

test('animal health records support update and delete for owner', function () {
    $animal = Animal::create([
        'name' => 'Health Cow',
        'type' => 'cattle',
        'user_id' => $this->user->id,
    ]);

    $headers = ['Authorization' => "Bearer {$this->token}"];

    $created = $this->postJson('/api/v1/animal-health-records', [
        'animal_id' => $animal->id,
        'type' => 'checkup',
        'name' => 'Routine exam',
        'notes' => 'Initial notes',
        'treated_at' => now()->toDateString(),
    ], $headers);

    $created->assertStatus(201);
    $id = (string) $created->json('id');

    $this->putJson("/api/v1/animal-health-records/{$id}", [
        'type' => 'treatment',
        'name' => 'Deworming',
        'notes' => 'Updated notes',
    ], $headers)
        ->assertStatus(200)
        ->assertJsonFragment([
            'type' => 'treatment',
            'name' => 'Deworming',
        ]);

    $this->deleteJson("/api/v1/animal-health-records/{$id}", [], $headers)
        ->assertStatus(204);

    $this->assertDatabaseMissing('animal_health_records', [
        'id' => $id,
        'user_id' => $this->user->id,
    ]);
});
