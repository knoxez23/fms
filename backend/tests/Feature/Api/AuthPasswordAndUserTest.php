<?php

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;

uses(RefreshDatabase::class);

test('authenticated user endpoint returns current user', function () {
    $user = User::factory()->create();
    $token = $user->createToken('test-token')->plainTextToken;

    $response = $this->getJson('/api/v1/user', [
        'Authorization' => "Bearer {$token}",
    ]);

    $response
        ->assertStatus(200)
        ->assertJson([
            'id' => $user->id,
            'email' => $user->email,
        ]);
});

test('forgot password sends reset link response for existing email', function () {
    $user = User::factory()->create();

    $response = $this->postJson('/api/v1/forgot-password', [
        'email' => $user->email,
    ]);

    $response
        ->assertStatus(200)
        ->assertJsonFragment(['message' => 'Password reset link sent to your email.']);
});

test('reset password accepts valid token and updates password', function () {
    $user = User::factory()->create();
    $token = Password::broker()->createToken($user);
    $newPassword = 'Str0ng!Password123';

    $response = $this->postJson('/api/v1/reset-password', [
        'token' => $token,
        'email' => $user->email,
        'password' => $newPassword,
        'password_confirmation' => $newPassword,
    ]);

    $response
        ->assertStatus(200)
        ->assertJsonFragment(['message' => 'Password reset successfully.']);

    $user->refresh();
    expect(Hash::check($newPassword, $user->password))->toBeTrue();
});
