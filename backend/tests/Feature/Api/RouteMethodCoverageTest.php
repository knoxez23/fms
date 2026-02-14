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
use App\Models\Task;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->user = User::factory()->create();
    $this->token = $this->user->createToken('test-token')->plainTextToken;
    $this->headers = ['Authorization' => "Bearer {$this->token}"];
});

test('core resources support show update and delete routes', function () {
    $animal = Animal::create([
        'name' => 'Cow 1',
        'type' => 'cattle',
        'user_id' => $this->user->id,
    ]);
    $this->getJson("/api/v1/animals/{$animal->id}", $this->headers)
        ->assertStatus(200)
        ->assertJsonFragment(['id' => $animal->id]);
    $this->putJson("/api/v1/animals/{$animal->id}", ['weight' => 333], $this->headers)
        ->assertStatus(200);
    $this->deleteJson("/api/v1/animals/{$animal->id}", [], $this->headers)
        ->assertStatus(204);

    $crop = Crop::create([
        'name' => 'Beans',
        'planted_date' => now()->toDateString(),
        'area' => 2.5,
        'status' => 'planted',
        'user_id' => $this->user->id,
    ]);
    $this->getJson("/api/v1/crops/{$crop->id}", $this->headers)->assertStatus(200);
    $this->putJson("/api/v1/crops/{$crop->id}", ['status' => 'growing'], $this->headers)
        ->assertStatus(200)
        ->assertJsonFragment(['status' => 'growing']);
    $this->deleteJson("/api/v1/crops/{$crop->id}", [], $this->headers)->assertStatus(204);

    $task = Task::create([
        'title' => 'Irrigate',
        'status' => 'pending',
        'user_id' => $this->user->id,
    ]);
    $this->getJson("/api/v1/tasks/{$task->id}", $this->headers)->assertStatus(200);
    $this->putJson("/api/v1/tasks/{$task->id}", ['status' => 'completed'], $this->headers)
        ->assertStatus(200)
        ->assertJsonFragment(['status' => 'completed']);
    $this->deleteJson("/api/v1/tasks/{$task->id}", [], $this->headers)->assertStatus(204);

    $sale = Sale::create([
        'product_name' => 'Milk',
        'quantity' => 10,
        'price' => 50,
        'date' => now()->toDateString(),
        'user_id' => $this->user->id,
    ]);
    $this->getJson("/api/v1/sales/{$sale->id}", $this->headers)->assertStatus(200);
    $this->putJson("/api/v1/sales/{$sale->id}", ['price' => 55], $this->headers)
        ->assertStatus(200);
    $this->deleteJson("/api/v1/sales/{$sale->id}", [], $this->headers)->assertStatus(204);

    $inventory = Inventory::create([
        'item_name' => 'Feed',
        'category' => 'Animal',
        'quantity' => 20,
        'unit' => 'kg',
        'user_id' => $this->user->id,
        'is_synced' => true,
    ]);
    $this->getJson("/api/v1/inventories/{$inventory->id}", $this->headers)->assertStatus(200);
    $this->putJson("/api/v1/inventories/{$inventory->id}", ['quantity' => 18], $this->headers)
        ->assertStatus(200)
        ->assertJsonFragment(['quantity' => 18]);
    $this->deleteJson("/api/v1/inventories/{$inventory->id}", [], $this->headers)->assertStatus(204);
});

test('feeding and animal records support show update and delete routes', function () {
    $animal = Animal::create([
        'name' => 'Goat 1',
        'type' => 'goat',
        'user_id' => $this->user->id,
    ]);

    $schedule = FeedingSchedule::create([
        'animal_id' => $animal->id,
        'feed_type' => 'Hay',
        'quantity' => 3,
        'unit' => 'kg',
        'time_of_day' => 'morning',
        'frequency' => 'daily',
    ]);
    $this->getJson("/api/v1/feeding-schedules/{$schedule->id}", $this->headers)->assertStatus(200);
    $this->putJson("/api/v1/feeding-schedules/{$schedule->id}", ['completed' => true], $this->headers)
        ->assertStatus(200)
        ->assertJsonFragment(['completed' => true]);
    $this->deleteJson("/api/v1/feeding-schedules/{$schedule->id}", [], $this->headers)->assertStatus(204);

    $log = FeedingLog::create([
        'animal_id' => $animal->id,
        'feed_type' => 'Pellets',
        'quantity' => 2,
        'unit' => 'kg',
        'fed_at' => now()->toDateTimeString(),
    ]);
    $this->getJson("/api/v1/feeding-logs/{$log->id}", $this->headers)->assertStatus(200);
    $this->putJson("/api/v1/feeding-logs/{$log->id}", ['fed_by' => 'Worker A'], $this->headers)
        ->assertStatus(200)
        ->assertJsonFragment(['fed_by' => 'Worker A']);
    $this->deleteJson("/api/v1/feeding-logs/{$log->id}", [], $this->headers)->assertStatus(204);

    $weight = AnimalWeight::create([
        'animal_id' => $animal->id,
        'user_id' => $this->user->id,
        'weight' => 45,
        'recorded_at' => now()->toDateString(),
    ]);
    $this->getJson("/api/v1/animal-weights/{$weight->id}", $this->headers)->assertStatus(200);
    $this->putJson("/api/v1/animal-weights/{$weight->id}", ['weight' => 46], $this->headers)
        ->assertStatus(200);
    $this->deleteJson("/api/v1/animal-weights/{$weight->id}", [], $this->headers)->assertStatus(204);

    $health = AnimalHealthRecord::create([
        'animal_id' => $animal->id,
        'user_id' => $this->user->id,
        'type' => 'treatment',
        'name' => 'Deworming',
    ]);
    $this->getJson("/api/v1/animal-health-records/{$health->id}", $this->headers)->assertStatus(200);
    $this->putJson("/api/v1/animal-health-records/{$health->id}", ['name' => 'Vaccination'], $this->headers)
        ->assertStatus(200)
        ->assertJsonFragment(['name' => 'Vaccination']);
    $this->deleteJson("/api/v1/animal-health-records/{$health->id}", [], $this->headers)->assertStatus(204);

    $production = AnimalProductionLog::create([
        'animal_id' => $animal->id,
        'user_id' => $this->user->id,
        'type' => 'milk',
        'quantity' => 4.2,
        'unit' => 'liters',
    ]);
    $this->getJson("/api/v1/animal-production-logs/{$production->id}", $this->headers)->assertStatus(200);
    $this->putJson("/api/v1/animal-production-logs/{$production->id}", ['quantity' => 5.0], $this->headers)
        ->assertStatus(200);
    $this->deleteJson("/api/v1/animal-production-logs/{$production->id}", [], $this->headers)->assertStatus(204);
});
