<?php

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

test('authenticated user can fetch weather payload', function () {
    $user = User::factory()->create();
    $token = $user->createToken('test-token')->plainTextToken;

    $response = $this->getJson('/api/v1/weather', [
        'Authorization' => "Bearer {$token}",
    ]);

    $response->assertStatus(200)
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
            'weekly',
        ]);
});

test('weather endpoint validates latitude and longitude bounds', function () {
    $user = User::factory()->create();
    $token = $user->createToken('test-token')->plainTextToken;

    $response = $this->getJson('/api/v1/weather?lat=120&lon=250', [
        'Authorization' => "Bearer {$token}",
    ]);

    $response->assertStatus(422)
        ->assertJsonValidationErrors(['lat', 'lon']);
});
