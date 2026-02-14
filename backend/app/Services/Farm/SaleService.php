<?php

namespace App\Services\Farm;

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
        return Sale::create(array_merge($validated, ['user_id' => $userId]));
    }

    public function updateForUser(int $userId, string $saleId, array $validated): Sale
    {
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
}
