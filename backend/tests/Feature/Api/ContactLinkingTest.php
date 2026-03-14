<?php

use App\Models\Customer;
use App\Models\StaffMember;
use App\Models\Supplier;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->user = User::factory()->create();
    $this->token = $this->user->createToken('test-token')->plainTextToken;

    $this->otherUser = User::factory()->create();
    $this->otherToken = $this->otherUser->createToken('other-token')->plainTextToken;
});

test('inventory accepts owned supplier_id and mirrors supplier name', function () {
    $supplier = Supplier::create([
        'user_id' => $this->user->id,
        'name' => 'Agro Hub',
    ]);

    $response = $this->postJson('/api/v1/inventories', [
        'item_name' => 'Layer Feed',
        'category' => 'Animal Feed',
        'quantity' => 10,
        'unit' => 'bags',
        'min_stock' => 2,
        'supplier_id' => $supplier->id,
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $response->assertStatus(201)->assertJsonFragment([
        'supplier_id' => $supplier->id,
        'supplier' => 'Agro Hub',
    ]);
});

test('inventory rejects supplier_id that belongs to another user', function () {
    $otherSupplier = Supplier::create([
        'user_id' => $this->otherUser->id,
        'name' => 'Other Supplier',
    ]);

    $this->postJson('/api/v1/inventories', [
        'item_name' => 'NPK',
        'category' => 'Fertilizers',
        'quantity' => 5,
        'unit' => 'bags',
        'supplier_id' => $otherSupplier->id,
    ], [
        'Authorization' => "Bearer {$this->token}",
    ])->assertStatus(404);
});

test('sales accepts owned customer_id and mirrors customer_name', function () {
    $customer = Customer::create([
        'user_id' => $this->user->id,
        'name' => 'Maziwa Co-op',
    ]);

    $response = $this->postJson('/api/v1/sales', [
        'product_name' => 'Milk',
        'quantity' => 25,
        'unit' => 'liters',
        'price' => 60,
        'total_amount' => 1500,
        'customer_id' => $customer->id,
        'sale_date' => now()->toDateString(),
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $response->assertStatus(201)->assertJsonFragment([
        'customer_id' => $customer->id,
        'customer_name' => 'Maziwa Co-op',
    ]);
});

test('sales rejects customer_id that belongs to another user', function () {
    $otherCustomer = Customer::create([
        'user_id' => $this->otherUser->id,
        'name' => 'Other Buyer',
    ]);

    $this->postJson('/api/v1/sales', [
        'product_name' => 'Eggs',
        'quantity' => 20,
        'unit' => 'trays',
        'price' => 400,
        'date' => now()->toDateString(),
        'customer_id' => $otherCustomer->id,
    ], [
        'Authorization' => "Bearer {$this->token}",
    ])->assertStatus(404);
});

test('tasks accepts owned staff_member_id and mirrors assigned_to', function () {
    $staff = StaffMember::create([
        'user_id' => $this->user->id,
        'name' => 'Peter K.',
    ]);

    $response = $this->postJson('/api/v1/tasks', [
        'title' => 'Irrigate field B',
        'description' => 'Open drip line',
        'due_date' => now()->addDay()->toDateString(),
        'staff_member_id' => $staff->id,
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $response->assertStatus(201)->assertJsonFragment([
        'staff_member_id' => $staff->id,
        'assigned_to' => 'Peter K.',
    ]);
});

test('staff records support richer role and work context fields', function () {
    $response = $this->postJson('/api/v1/staff-members', [
        'name' => 'Grace',
        'role' => 'Accountant',
        'employment_status' => 'active',
        'assignment_area' => 'Finance desk',
        'can_login' => true,
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $response->assertCreated()->assertJsonFragment([
        'name' => 'Grace',
        'role' => 'Accountant',
        'employment_status' => 'active',
        'assignment_area' => 'Finance desk',
        'can_login' => true,
    ]);
});

test('tasks rejects staff_member_id that belongs to another user', function () {
    $otherStaff = StaffMember::create([
        'user_id' => $this->otherUser->id,
        'name' => 'Other Staff',
    ]);

    $this->postJson('/api/v1/tasks', [
        'title' => 'Spray tomatoes',
        'staff_member_id' => $otherStaff->id,
    ], [
        'Authorization' => "Bearer {$this->token}",
    ])->assertStatus(404);
});

test('inventory update rejects supplier_id from another user', function () {
    $inventory = $this->postJson('/api/v1/inventories', [
        'item_name' => 'Starter feed',
        'category' => 'Animal Feed',
        'quantity' => 4,
        'unit' => 'bags',
    ], [
        'Authorization' => "Bearer {$this->token}",
    ])->assertStatus(201)->json();

    $otherSupplier = Supplier::create([
        'user_id' => $this->otherUser->id,
        'name' => 'External Supplier',
    ]);

    $this->putJson("/api/v1/inventories/{$inventory['id']}", [
        'supplier_id' => $otherSupplier->id,
    ], [
        'Authorization' => "Bearer {$this->token}",
    ])->assertStatus(404);
});

test('sale update rejects customer_id from another user', function () {
    $sale = $this->postJson('/api/v1/sales', [
        'product_name' => 'Milk',
        'quantity' => 10,
        'unit' => 'liters',
        'price' => 55,
        'date' => now()->toDateString(),
    ], [
        'Authorization' => "Bearer {$this->token}",
    ])->assertStatus(201)->json();

    $otherCustomer = Customer::create([
        'user_id' => $this->otherUser->id,
        'name' => 'External Customer',
    ]);

    $this->putJson("/api/v1/sales/{$sale['id']}", [
        'customer_id' => $otherCustomer->id,
    ], [
        'Authorization' => "Bearer {$this->token}",
    ])->assertStatus(404);
});

test('task update rejects staff_member_id from another user', function () {
    $task = $this->postJson('/api/v1/tasks', [
        'title' => 'Weed maize',
    ], [
        'Authorization' => "Bearer {$this->token}",
    ])->assertStatus(201)->json();

    $otherStaff = StaffMember::create([
        'user_id' => $this->otherUser->id,
        'name' => 'External Staff',
    ]);

    $this->putJson("/api/v1/tasks/{$task['id']}", [
        'staff_member_id' => $otherStaff->id,
    ], [
        'Authorization' => "Bearer {$this->token}",
    ])->assertStatus(404);
});
