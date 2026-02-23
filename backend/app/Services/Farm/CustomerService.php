<?php

namespace App\Services\Farm;

use App\Models\Customer;
use Illuminate\Support\Collection;

class CustomerService
{
    /**
     * @return Collection<int, Customer>
     */
    public function listForUser(int $userId): Collection
    {
        return Customer::where('user_id', $userId)->orderBy('name')->get();
    }

    public function createForUser(int $userId, array $validated): Customer
    {
        return Customer::create(array_merge($validated, ['user_id' => $userId]));
    }

    public function showForUser(int $userId, string $id): Customer
    {
        return Customer::where('user_id', $userId)->where('id', $id)->firstOrFail();
    }

    public function updateForUser(int $userId, string $id, array $validated): Customer
    {
        $customer = $this->showForUser($userId, $id);
        $customer->update($validated);

        return $customer;
    }

    public function deleteForUser(int $userId, string $id): void
    {
        $customer = $this->showForUser($userId, $id);
        $customer->delete();
    }
}
