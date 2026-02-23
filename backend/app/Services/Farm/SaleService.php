<?php

namespace App\Services\Farm;

use App\Models\Customer;
use App\Models\Sale;
use Illuminate\Support\Collection;

class SaleService
{
    /**
     * @return Collection<int, Sale>
     */
    public function listForUser(int $userId): Collection
    {
        return Sale::where('user_id', $userId)
            ->orderBy('sale_date', 'desc')
            ->get();
    }

    public function createForUser(int $userId, array $validated): Sale
    {
        $validated = $this->attachOwnedCustomerName($userId, $validated);
        return Sale::create(array_merge($validated, ['user_id' => $userId]));
    }

    public function updateForUser(int $userId, string $saleId, array $validated): Sale
    {
        $validated = $this->attachOwnedCustomerName($userId, $validated);
        $sale = Sale::where('id', $saleId)
            ->where('user_id', $userId)
            ->firstOrFail();

        $sale->update($validated);
        return $sale;
    }

    public function showForUser(int $userId, string $saleId): Sale
    {
        return Sale::where('id', $saleId)
            ->where('user_id', $userId)
            ->firstOrFail();
    }

    public function deleteForUser(int $userId, string $saleId): void
    {
        $sale = Sale::where('id', $saleId)
            ->where('user_id', $userId)
            ->firstOrFail();

        $sale->delete();
    }

    private function attachOwnedCustomerName(int $userId, array $validated): array
    {
        if (! isset($validated['customer_id'])) {
            return $validated;
        }

        $customer = Customer::where('user_id', $userId)
            ->where('id', $validated['customer_id'])
            ->firstOrFail();

        if (! isset($validated['customer_name']) || empty(trim((string) $validated['customer_name']))) {
            $validated['customer_name'] = $customer->name;
        }

        return $validated;
    }
}
