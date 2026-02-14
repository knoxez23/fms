<?php

use App\Models\Role;
use App\Models\User;
use App\Http\Middleware\CheckPermission;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\HttpException;

uses(RefreshDatabase::class);

test('newly registered user gets owner role', function () {
    $response = $this->postJson('/api/v1/register', [
        'name' => 'Owner User',
        'email' => 'owner@example.com',
        'password' => 'StrongPass123!@',
        'password_confirmation' => 'StrongPass123!@',
    ]);

    $response->assertCreated();

    $user = User::where('email', 'owner@example.com')->firstOrFail();
    $ownerRole = Role::where('name', 'owner')->firstOrFail();

    expect($user->roles()->where('roles.id', $ownerRole->id)->exists())->toBeTrue();
    expect($user->fresh()->hasPermission('inventory.delete'))->toBeTrue();
});

test('permission middleware logic allows authorized users and rejects unauthorized users', function () {
    $worker = User::factory()->create();
    $workerRole = Role::where('name', 'worker')->firstOrFail();
    $worker->roles()->attach($workerRole->id, ['assigned_by' => $worker->id]);

    expect($worker->fresh()->hasPermission('inventory.read'))->toBeTrue();

    $guest = User::factory()->create();
    expect($guest->fresh()->hasPermission('inventory.read'))->toBeFalse();

    $request = Request::create('/api/v1/anything', 'GET');
    $request->setUserResolver(fn () => $guest);
    $middleware = new CheckPermission();

    expect(fn () => $middleware->handle(
        $request,
        fn () => response()->json(['ok' => true]),
        'inventory.read'
    ))->toThrow(HttpException::class);
});
