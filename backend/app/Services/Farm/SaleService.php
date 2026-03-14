<?php

namespace App\Services\Farm;

use App\Models\Customer;
use App\Models\Inventory;
use App\Models\Sale;
use App\Services\Audit\AuditEventService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Collection;

class SaleService
{
    public function __construct(
        private readonly AuditEventService $auditService,
        private readonly FarmContextService $farmContextService,
    )
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
        $this->farmContextService->assertCanManageCommercialOps($userId);

        $sale = DB::transaction(function () use ($userId, $validated) {
            $validated = $this->attachOwnedCustomerName($userId, $validated);
            $validated = $this->applyStockDeductions($userId, $validated);

            return Sale::create(array_merge($validated, ['user_id' => $userId]));
        });

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
                'stock_deduction_plan' => $sale->stock_deduction_plan,
                'summary' => "Recorded sale of {$sale->product_name} worth {$sale->total_amount}.",
            ]
        );

        return $sale;
    }

    public function updateForUser(int $userId, string $saleId, array $validated): Sale
    {
        $this->farmContextService->assertCanManageCommercialOps($userId);

        $sale = DB::transaction(function () use ($userId, $saleId, $validated) {
            $sale = Sale::where('id', $saleId)
                ->where('user_id', $userId)
                ->firstOrFail();

            $this->restoreStockDeductions($sale->stock_deduction_plan);

            $validated = $this->attachOwnedCustomerName($userId, $validated);
            $validated = $this->applyStockDeductions($userId, $validated);

            $sale->update($validated);

            return $sale->fresh();
        });

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
        $this->farmContextService->assertCanManageCommercialOps($userId);

        [$saleRef, $productName, $totalAmount] = DB::transaction(function () use ($userId, $saleId) {
            $sale = Sale::where('id', $saleId)
                ->where('user_id', $userId)
                ->firstOrFail();
            $saleRef = (string) $sale->id;
            $productName = $sale->product_name;
            $totalAmount = $sale->total_amount;
            $this->restoreStockDeductions($sale->stock_deduction_plan);
            $sale->delete();

            return [$saleRef, $productName, $totalAmount];
        });

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

    private function applyStockDeductions(int $userId, array $validated): array
    {
        $productName = trim((string) ($validated['product_name'] ?? ''));
        $unit = trim((string) ($validated['unit'] ?? ''));
        $quantity = isset($validated['quantity']) ? (float) $validated['quantity'] : 0.0;

        if ($productName === '' || $unit === '' || $quantity <= 0) {
            $validated['stock_deduction_plan'] = null;

            return $validated;
        }

        $items = Inventory::query()
            ->where('user_id', $userId)
            ->whereRaw('LOWER(item_name) = ?', [mb_strtolower($productName)])
            ->whereRaw('LOWER(unit) = ?', [mb_strtolower($unit)])
            ->where('quantity', '>', 0)
            ->orderByRaw('CASE WHEN last_restock IS NULL THEN 1 ELSE 0 END')
            ->orderBy('last_restock')
            ->orderBy('id')
            ->get();

        $remaining = $quantity;
        $plan = [];

        foreach ($items as $item) {
            if ($remaining <= 0) {
                break;
            }

            $available = (float) $item->quantity;
            if ($available <= 0) {
                continue;
            }

            $deducted = min($available, $remaining);
            $item->quantity = round($available - $deducted, 2);
            if ($item->unit_price !== null) {
                $item->total_value = round($item->quantity * (float) $item->unit_price, 2);
            }
            $item->save();

            $plan[] = [
                'inventory_id' => $item->id,
                'client_uuid' => $item->client_uuid,
                'quantity' => round($deducted, 2),
                'item_name' => $item->item_name,
                'unit' => $item->unit,
                'lot_label' => $this->lotLabelForInventory($item),
            ];

            $remaining -= $deducted;
        }

        $validated['stock_deduction_plan'] = empty($plan) ? null : $plan;

        return $validated;
    }

    private function restoreStockDeductions(mixed $plan): void
    {
        if (! is_array($plan)) {
            return;
        }

        foreach ($plan as $entry) {
            if (! is_array($entry)) {
                continue;
            }

            $inventoryId = isset($entry['inventory_id']) ? (int) $entry['inventory_id'] : null;
            $quantity = isset($entry['quantity']) ? (float) $entry['quantity'] : 0.0;
            if ($inventoryId === null || $quantity <= 0) {
                continue;
            }

            $item = Inventory::query()->find($inventoryId);
            if ($item === null) {
                continue;
            }

            $item->quantity = round(((float) $item->quantity) + $quantity, 2);
            if ($item->unit_price !== null) {
                $item->total_value = round($item->quantity * (float) $item->unit_price, 2);
            }
            $item->save();
        }
    }

    private function lotLabelForInventory(Inventory $item): string
    {
        $timestamp = $item->last_restock?->format('M j');

        return $timestamp === null ? 'Current lot' : "Lot from {$timestamp}";
    }
}
