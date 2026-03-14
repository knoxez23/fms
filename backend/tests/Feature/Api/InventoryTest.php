<?php

use App\Models\User;
use App\Models\Inventory;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->user = User::factory()->create();
    $this->token = $this->user->createToken('test-token')->plainTextToken;
});

test('authenticated user can create inventory item', function () {
    $response = $this->postJson('/api/v1/inventories', [
        'item_name' => 'Chicken Feed',
        'category' => 'Feed',
        'quantity' => 100,
        'unit' => 'kg',
        'min_stock' => 20,
        'unit_price' => 50.00,
        'supplier' => 'ABC Suppliers',
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $response->assertStatus(201)
        ->assertJsonStructure([
            'id',
            'item_name',
            'category',
            'quantity',
            'unit',
        ]);

    $this->assertDatabaseHas('inventories', [
        'item_name' => 'Chicken Feed',
        'user_id' => $this->user->id,
    ]);
});

test('inventory total value is derived on create and ignores client override', function () {
    $response = $this->postJson('/api/v1/inventories', [
        'item_name' => 'Dairy Meal',
        'category' => 'Feed',
        'quantity' => 12,
        'unit' => 'kg',
        'unit_price' => 100,
        'total_value' => 1, // should be ignored server-side
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $response->assertStatus(201)
        ->assertJsonPath('total_value', 1200);

    $this->assertDatabaseHas('inventories', [
        'item_name' => 'Dairy Meal',
        'user_id' => $this->user->id,
        'total_value' => 1200,
    ]);
});

test('inventory create is idempotent by client_uuid', function () {
    $payload = [
        'client_uuid' => '8b5a4e4f-6c74-4f5e-9c2e-01f69f73a9c2',
        'item_name' => 'Maize Seed',
        'category' => 'Seeds',
        'quantity' => 25,
        'unit' => 'kg',
        'min_stock' => 5,
    ];

    $first = $this->postJson('/api/v1/inventories', $payload, [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $first->assertStatus(201);

    $second = $this->postJson('/api/v1/inventories', $payload, [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $second->assertStatus(200);

    $this->assertDatabaseCount('inventories', 1);
    $this->assertDatabaseHas('inventories', [
        'client_uuid' => $payload['client_uuid'],
        'user_id' => $this->user->id,
    ]);
});

test('user can only see their own inventory items', function () {
    Inventory::factory()->count(3)->create(['user_id' => $this->user->id]);

    $otherUser = User::factory()->create();
    Inventory::factory()->count(2)->create(['user_id' => $otherUser->id]);

    $response = $this->getJson('/api/v1/inventories', [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $response->assertStatus(200)
        ->assertJsonCount(3);
});

test('user can update their inventory item', function () {
    $inventory = Inventory::factory()->create(['user_id' => $this->user->id]);

    $response = $this->putJson("/api/v1/inventories/{$inventory->id}", [
        'quantity' => 150,
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $response->assertStatus(200);

    $this->assertDatabaseHas('inventories', [
        'id' => $inventory->id,
        'quantity' => 150,
    ]);
});

test('inventory total value is re-derived on update when quantity or unit price changes', function () {
    $inventory = Inventory::factory()->create([
        'user_id' => $this->user->id,
        'quantity' => 10,
        'unit_price' => 50,
        'total_value' => 500,
    ]);

    $response = $this->putJson("/api/v1/inventories/{$inventory->id}", [
        'quantity' => 20,
        'total_value' => 5, // should be ignored server-side
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $response->assertStatus(200)
        ->assertJsonPath('total_value', 1000);

    $this->assertDatabaseHas('inventories', [
        'id' => $inventory->id,
        'quantity' => 20,
        'unit_price' => 50,
        'total_value' => 1000,
    ]);
});

test('user cannot update another user inventory item', function () {
    $otherUser = User::factory()->create();
    $inventory = Inventory::factory()->create(['user_id' => $otherUser->id]);

    $response = $this->putJson("/api/v1/inventories/{$inventory->id}", [
        'quantity' => 150,
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $response->assertStatus(404);
});

test('user can delete their inventory item', function () {
    $inventory = Inventory::factory()->create(['user_id' => $this->user->id]);

    $response = $this->deleteJson("/api/v1/inventories/{$inventory->id}", [], [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $response->assertStatus(204);

    $this->assertDatabaseMissing('inventories', [
        'id' => $inventory->id,
    ]);
});

test('delete by client_uuid is idempotent', function () {
    $inventory = Inventory::factory()->create([
        'user_id' => $this->user->id,
        'client_uuid' => 'de305d54-75b4-431b-adb2-eb6b9e546014',
    ]);

    $response = $this->deleteJson(
        '/api/v1/inventories/by-client/de305d54-75b4-431b-adb2-eb6b9e546014',
        [],
        ['Authorization' => "Bearer {$this->token}"]
    );

    $response->assertStatus(204);
    $this->assertDatabaseMissing('inventories', ['id' => $inventory->id]);

    $second = $this->deleteJson(
        '/api/v1/inventories/by-client/de305d54-75b4-431b-adb2-eb6b9e546014',
        [],
        ['Authorization' => "Bearer {$this->token}"]
    );
    $second->assertStatus(204);
});

test('sale create deducts matched output inventory and delete restores it', function () {
    $inventory = Inventory::factory()->create([
        'user_id' => $this->user->id,
        'item_name' => 'Milk',
        'category' => 'Dairy',
        'quantity' => 40,
        'unit' => 'liters',
        'unit_price' => 55,
        'total_value' => 2200,
        'last_restock' => now()->subHours(6),
    ]);

    $response = $this->postJson('/api/v1/sales', [
        'product_name' => 'Milk',
        'quantity' => 15,
        'unit' => 'liters',
        'price' => 60,
        'total_amount' => 900,
        'date' => now()->toDateString(),
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $sale = $response->assertCreated()->json();

    $this->assertDatabaseHas('inventories', [
        'id' => $inventory->id,
        'quantity' => 25,
        'total_value' => 1375,
    ]);

    expect($sale['stock_deduction_plan'])->toBeArray();
    expect($sale['stock_deduction_plan'][0]['inventory_id'])->toBe($inventory->id);

    $this->deleteJson("/api/v1/sales/{$sale['id']}", [], [
        'Authorization' => "Bearer {$this->token}",
    ])->assertNoContent();

    $this->assertDatabaseHas('inventories', [
        'id' => $inventory->id,
        'quantity' => 40,
        'total_value' => 2200,
    ]);
});
