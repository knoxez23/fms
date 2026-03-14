<?php

namespace App\Services\Farm;

use App\Models\Customer;
use App\Models\Sale;
use App\Services\Audit\AuditEventService;
use Illuminate\Support\Collection;

class SaleService
{
    public function __construct(private readonly AuditEventService $auditService)
    {
    }

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
        $sale = Sale::create(array_merge($validated, ['user_id' => $userId]));

        $this->auditService->record(
            userId: $userId,
            eventType: 'sale.created',
            entityType: 'sale',
            entityId: (string) $sale->id,
            metadata: [
                'product_name' => $sale->product_name,
                'quantity' => $sale->quantity,
                'unit' => $sale->unit,
                'total_amount' => $sale->total_amount,
                'payment_status' => $sale->payment_status,
                'summary' => "Recorded sale of {$sale->product_name} worth {$sale->total_amount}.",
            ]
        );

        return $sale;
    }

    public function updateForUser(int $userId, string $saleId, array $validated): Sale
    {
        $validated = $this->attachOwnedCustomerName($userId, $validated);
        $sale = Sale::where('id', $saleId)
            ->where('user_id', $userId)
            ->firstOrFail();

        $sale->update($validated);

        $this->auditService->record(
            userId: $userId,
            eventType: 'sale.updated',
            entityType: 'sale',
            entityId: (string) $sale->id,
            metadata: [
                'product_name' => $sale->product_name,
                'total_amount' => $sale->total_amount,
                'payment_status' => $sale->payment_status,
                'changed_fields' => array_keys($validated),
                'summary' => "Updated sale {$sale->product_name}.",
            ]
        );

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
        $saleRef = (string) $sale->id;
        $productName = $sale->product_name;
        $totalAmount = $sale->total_amount;
        $sale->delete();

        $this->auditService->record(
            userId: $userId,
            eventType: 'sale.deleted',
            entityType: 'sale',
            entityId: $saleRef,
            metadata: [
                'product_name' => $productName,
                'total_amount' => $totalAmount,
                'summary' => "Deleted sale record for {$productName}.",
            ]
        );
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
