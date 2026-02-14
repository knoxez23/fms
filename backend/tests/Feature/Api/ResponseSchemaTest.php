<?php

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

function authHeadersFor(User $user): array
{
    $token = $user->createToken('test-token')->plainTextToken;

    return [
        'Authorization' => "Bearer {$token}",
        'Accept' => 'application/json',
    ];
}

test('core resources return stable response schema for create/show/index', function () {
    $user = User::factory()->create();
    $headers = authHeadersFor($user);

    $animal = $this->postJson('/api/v1/animals', [
        'name' => 'Daisy',
        'type' => 'cow',
    ], $headers)
        ->assertCreated()
        ->assertJsonStructure([
            'id',
            'name',
            'type',
            'breed',
            'age',
            'weight',
            'health_status',
            'date_acquired',
            'notes',
            'created_at',
            'updated_at',
        ])
        ->json();

    $crop = $this->postJson('/api/v1/crops', [
        'name' => 'Maize',
        'planted_date' => now()->toDateString(),
        'area' => 2.5,
        'status' => 'planted',
    ], $headers)
        ->assertCreated()
        ->assertJsonStructure([
            'id',
            'name',
            'variety',
            'planted_date',
            'expected_harvest_date',
            'area',
            'status',
            'notes',
            'created_at',
            'updated_at',
        ])
        ->json();

    $task = $this->postJson('/api/v1/tasks', [
        'title' => 'Irrigate field A',
        'status' => 'pending',
    ], $headers)
        ->assertCreated()
        ->assertJsonStructure([
            'id',
            'title',
            'description',
            'due_date',
            'priority',
            'status',
            'category',
            'assigned_to',
            'source_event_type',
            'source_event_id',
            'created_at',
            'updated_at',
        ])
        ->json();

    $sale = $this->postJson('/api/v1/sales', [
        'product_name' => 'Milk',
        'quantity' => 20,
        'price' => 1.5,
        'date' => now()->toDateString(),
    ], $headers)
        ->assertCreated()
        ->assertJsonStructure([
            'id',
            'product_name',
            'quantity',
            'price',
            'date',
            'sale_date',
            'created_at',
            'updated_at',
        ])
        ->json();

    $this->getJson("/api/v1/animals/{$animal['id']}", $headers)
        ->assertOk()
        ->assertJsonPath('id', $animal['id'])
        ->assertJsonStructure(['id', 'name', 'type']);

    $this->getJson('/api/v1/animals', $headers)
        ->assertOk()
        ->assertJsonStructure([
            [
                'id',
                'name',
                'type',
                'created_at',
            ],
        ]);

    $this->getJson('/api/v1/crops', $headers)
        ->assertOk()
        ->assertJsonStructure([
            [
                'id',
                'name',
                'status',
                'created_at',
            ],
        ]);

    $this->getJson('/api/v1/tasks', $headers)
        ->assertOk()
        ->assertJsonStructure([
            [
                'id',
                'title',
                'status',
                'created_at',
            ],
        ]);

    $this->getJson('/api/v1/sales', $headers)
        ->assertOk()
        ->assertJsonStructure([
            [
                'id',
                'product_name',
                'quantity',
                'price',
                'date',
            ],
        ]);

    // Use values to avoid accidental dead code from static analyzers.
    expect($crop['id'])->toBeInt();
    expect($task['id'])->toBeInt();
    expect($sale['id'])->toBeInt();
});

test('inventory and weather endpoints keep expected response contracts', function () {
    $user = User::factory()->create();
    $headers = authHeadersFor($user);

    $inventory = $this->postJson('/api/v1/inventories', [
        'client_uuid' => (string) str()->uuid(),
        'item_name' => 'Layer feed',
        'category' => 'feed',
        'quantity' => 50,
        'unit' => 'kg',
    ], $headers)
        ->assertCreated()
        ->assertJsonStructure([
            'id',
            'client_uuid',
            'item_name',
            'category',
            'quantity',
            'unit',
            'min_stock',
            'supplier',
            'unit_price',
            'total_value',
            'notes',
            'last_restock',
            'is_synced',
            'created_at',
            'updated_at',
        ])
        ->json();

    $this->getJson('/api/v1/inventories', $headers)
        ->assertOk()
        ->assertJsonStructure([
            [
                'id',
                'client_uuid',
                'item_name',
                'quantity',
                'is_synced',
            ],
        ]);

    $this->getJson('/api/v1/weather?lat=-1.286389&lon=36.817223', $headers)
        ->assertOk()
        ->assertJsonStructure([
            'current' => [
                'temp',
                'condition',
                'icon',
                'humidity',
                'wind',
                'rain_chance',
                'advice',
            ],
            'weekly' => [
                [
                    'day',
                    'temp',
                    'condition',
                    'icon',
                    'rain_chance',
                ],
            ],
        ]);

    expect($inventory['id'])->toBeInt();
});
