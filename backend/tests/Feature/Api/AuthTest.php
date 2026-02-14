<?php

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;

uses(RefreshDatabase::class);

test('user can register with valid data', function () {
    $response = $this->postJson('/api/v1/register', [
        'name' => 'Test User',
        'email' => 'test@example.com',
        'password' => 'StrongPass123!@',
        'password_confirmation' => 'StrongPass123!@',
    ]);

    $response->assertStatus(201)
        ->assertJsonStructure([
            'user' => ['id', 'name', 'email'],
            'access_token',
            'refresh_token',
            'expires_at',
        ]);

    $this->assertDatabaseHas('users', [
        'email' => 'test@example.com',
        'name' => 'Test User',
    ]);
});

test('user cannot register with weak password', function () {
    $response = $this->postJson('/api/v1/register', [
        'name' => 'Test User',
        'email' => 'test@example.com',
        'password' => 'weak',
        'password_confirmation' => 'weak',
    ]);

    $response->assertStatus(422)
        ->assertJsonValidationErrors(['password']);
});

test('user cannot register with duplicate email', function () {
    User::factory()->create(['email' => 'test@example.com']);

    $response = $this->postJson('/api/v1/register', [
        'name' => 'Test User',
        'email' => 'test@example.com',
        'password' => 'StrongPass123!@',
        'password_confirmation' => 'StrongPass123!@',
    ]);

    $response->assertStatus(422)
        ->assertJsonValidationErrors(['email']);
});

test('user can login with correct credentials', function () {
    $user = User::factory()->create([
        'email' => 'test@example.com',
        'password' => Hash::make('StrongPass123!@'),
    ]);

    $response = $this->postJson('/api/v1/login', [
        'email' => $user->email,
        'password' => 'StrongPass123!@',
    ]);

    $response->assertStatus(200)
        ->assertJsonStructure([
            'user' => ['id', 'name', 'email'],
            'access_token',
            'refresh_token',
            'expires_at',
        ]);
});

test('user cannot login with wrong credentials', function () {
    User::factory()->create([
        'email' => 'test@example.com',
        'password' => Hash::make('correct-password'),
    ]);

    $response = $this->postJson('/api/v1/login', [
        'email' => 'test@example.com',
        'password' => 'wrong-password',
    ]);

    $response->assertStatus(422)
        ->assertJsonValidationErrors(['email']);
});

test('login is rate limited', function () {
    $user = User::factory()->create([
        'password' => Hash::make('password'),
    ]);

    for ($i = 0; $i < 6; $i++) {
        $response = $this->postJson('/api/v1/login', [
            'email' => $user->email,
            'password' => 'wrong-password',
        ]);
    }

    $response->assertStatus(429);
});

test('authenticated user can logout', function () {
    $user = User::factory()->create();
    $token = $user->createToken('test-token')->plainTextToken;

    $response = $this->postJson('/api/v1/logout', [], [
        'Authorization' => "Bearer $token",
    ]);

    $response->assertStatus(200);

    $this->assertDatabaseMissing('personal_access_tokens', [
        'tokenable_id' => $user->id,
    ]);
});

test('user can refresh access token', function () {
    $user = User::factory()->create();

    $tokenService = new \App\Services\Auth\TokenService();
    $tokens = $tokenService->createTokenPair($user);

    $response = $this->postJson('/api/v1/refresh', [
        'refresh_token' => $tokens['refresh_token'],
    ]);

    $response->assertStatus(200)
        ->assertJsonStructure([
            'access_token',
            'refresh_token',
            'expires_at',
        ]);
});
