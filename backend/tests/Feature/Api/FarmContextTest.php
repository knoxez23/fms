<?php

use App\Models\FarmMembership;
use App\Models\StaffMember;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

test('register response includes current farm and membership context', function () {
    $response = $this->postJson('/api/v1/register', [
        'name' => 'Farm Owner',
        'email' => 'farm-owner@example.com',
        'password' => 'StrongPass123!@',
        'password_confirmation' => 'StrongPass123!@',
        'farm_name' => 'Green Valley',
        'location' => 'Nakuru',
    ]);

    $response->assertCreated()
        ->assertJsonPath('user.current_farm.name', 'Green Valley')
        ->assertJsonPath('user.current_membership.role', 'owner');

    $user = User::query()->where('email', 'farm-owner@example.com')->firstOrFail();
    expect(FarmMembership::query()->where('user_id', $user->id)->exists())->toBeTrue();
});

test('farm context endpoint returns current farm and team summary', function () {
    $user = User::factory()->create([
        'name' => 'Primary Owner',
        'farm_name' => 'Hilltop Farm',
    ]);
    $token = $user->createToken('test-token')->plainTextToken;

    $this->getJson('/api/v1/farm-context', [
        'Authorization' => "Bearer {$token}",
    ])->assertOk()->assertJsonPath('farm.name', 'Hilltop Farm');

    StaffMember::create([
        'user_id' => $user->id,
        'farm_id' => FarmMembership::query()->where('user_id', $user->id)->firstOrFail()->farm_id,
        'name' => 'Alice',
        'role' => 'Manager',
        'employment_status' => 'active',
    ]);

    StaffMember::create([
        'user_id' => $user->id,
        'farm_id' => FarmMembership::query()->where('user_id', $user->id)->firstOrFail()->farm_id,
        'name' => 'Ben',
        'role' => 'Worker',
        'employment_status' => 'seasonal',
    ]);

    $this->getJson('/api/v1/farm-context', [
        'Authorization' => "Bearer {$token}",
    ])->assertOk()
        ->assertJsonPath('team_summary.staff_count', 2)
        ->assertJsonPath('team_summary.active_staff_count', 1)
        ->assertJsonPath('membership.role', 'owner');
});

