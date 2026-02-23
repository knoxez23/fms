<?php

namespace App\Services\Farm;

use App\Models\Supplier;
use Illuminate\Support\Collection;

class SupplierService
{
    /**
     * @return Collection<int, Supplier>
     */
    public function listForUser(int $userId): Collection
    {
        return Supplier::where('user_id', $userId)->orderBy('name')->get();
    }

    public function createForUser(int $userId, array $validated): Supplier
    {
        return Supplier::create(array_merge($validated, ['user_id' => $userId]));
    }

    public function showForUser(int $userId, string $id): Supplier
    {
        return Supplier::where('user_id', $userId)->where('id', $id)->firstOrFail();
    }

    public function updateForUser(int $userId, string $id, array $validated): Supplier
    {
        $supplier = $this->showForUser($userId, $id);
        $supplier->update($validated);

        return $supplier;
    }

    public function deleteForUser(int $userId, string $id): void
    {
        $supplier = $this->showForUser($userId, $id);
        $supplier->delete();
    }
}
