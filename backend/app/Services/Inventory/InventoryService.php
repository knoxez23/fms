<?php

namespace App\Services\Inventory;

use App\Models\Inventory;
use App\Models\Supplier;
use App\Services\Audit\AuditEventService;
use Illuminate\Support\Collection;

class InventoryService
{
    public function __construct(private readonly AuditEventService $auditService)
    {
    }

    /**
     * @return Collection<int, Inventory>
     */
    public function listForUser(int $userId): Collection
    {
        return Inventory::where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->get();
    }

    /**
     * @return array{inventory: Inventory, status: int}
     */
    public function createOrUpsertByClientUuid(int $userId, array $validated): array
    {
        $validated = $this->attachOwnedSupplierName($userId, $validated);
        $clientUuid = $validated['client_uuid'] ?? null;

        if ($clientUuid) {
            $existing = Inventory::where('user_id', $userId)
                ->where('client_uuid', $clientUuid)
                ->first();

            if ($existing) {
                $validated = $this->normalizeValuation($validated, $existing);
                $existing->update($validated);
                $this->auditService->record(
                    userId: $userId,
                    eventType: 'inventory.upserted',
                    entityType: 'inventory',
                    entityId: (string) $existing->id,
                    metadata: [
                        'client_uuid' => $clientUuid,
                        'item_name' => $existing->item_name,
                    ]
                );

                return ['inventory' => $existing, 'status' => 200];
            }
        }

        $validated = $this->normalizeValuation($validated);

        $inventory = Inventory::create(array_merge($validated, [
            'user_id' => $userId,
            'is_synced' => true,
        ]));

        $this->auditService->record(
            userId: $userId,
            eventType: 'inventory.created',
            entityType: 'inventory',
            entityId: (string) $inventory->id,
            metadata: [
                'item_name' => $inventory->item_name,
                'quantity' => $inventory->quantity,
                'min_stock' => $inventory->min_stock,
            ]
        );

        return ['inventory' => $inventory, 'status' => 201];
    }

    public function updateForUser(int $userId, string $inventoryId, array $validated): Inventory
    {
        $validated = $this->attachOwnedSupplierName($userId, $validated);
        $inventory = Inventory::where('id', $inventoryId)
            ->where('user_id', $userId)
            ->firstOrFail();
        $validated = $this->normalizeValuation($validated, $inventory);

        $inventory->update($validated);

        $this->auditService->record(
            userId: $userId,
            eventType: 'inventory.updated',
            entityType: 'inventory',
            entityId: (string) $inventory->id,
            metadata: [
                'item_name' => $inventory->item_name,
                'quantity' => $inventory->quantity,
                'min_stock' => $inventory->min_stock,
            ]
        );

        return $inventory;
    }

    public function showForUser(int $userId, string $inventoryId): Inventory
    {
        return Inventory::where('id', $inventoryId)
            ->where('user_id', $userId)
            ->firstOrFail();
    }

    public function deleteForUser(int $userId, string $inventoryId): void
    {
        $inventory = Inventory::where('id', $inventoryId)
            ->where('user_id', $userId)
            ->firstOrFail();

        $inventoryRef = (string) $inventory->id;
        $itemName = $inventory->item_name;
        $inventory->delete();

        $this->auditService->record(
            userId: $userId,
            eventType: 'inventory.deleted',
            entityType: 'inventory',
            entityId: $inventoryRef,
            metadata: ['item_name' => $itemName]
        );
    }

    public function deleteByClientUuid(int $userId, string $clientUuid): void
    {
        $inventory = Inventory::where('user_id', $userId)
            ->where('client_uuid', $clientUuid)
            ->first();

        if (! $inventory) {
            return;
        }

        $inventoryId = (string) $inventory->id;
        $itemName = $inventory->item_name;
        $inventory->delete();

        $this->auditService->record(
            userId: $userId,
            eventType: 'inventory.deleted',
            entityType: 'inventory',
            entityId: $inventoryId,
            metadata: [
                'item_name' => $itemName,
                'client_uuid' => $clientUuid,
            ]
        );
    }

    private function attachOwnedSupplierName(int $userId, array $validated): array
    {
        if (! isset($validated['supplier_id'])) {
            return $validated;
        }

        $supplier = Supplier::where('user_id', $userId)
            ->where('id', $validated['supplier_id'])
            ->firstOrFail();

        if (! isset($validated['supplier']) || empty(trim((string) $validated['supplier']))) {
            $validated['supplier'] = $supplier->name;
        }

        return $validated;
    }

    private function normalizeValuation(array $validated, ?Inventory $existing = null): array
    {
        unset($validated['total_value']);

        $hasQuantity = array_key_exists('quantity', $validated);
        $hasUnitPrice = array_key_exists('unit_price', $validated);
        if (! $hasQuantity && ! $hasUnitPrice) {
            return $validated;
        }

        $quantity = isset($validated['quantity'])
            ? (float) $validated['quantity']
            : ($existing?->quantity);
        $unitPrice = isset($validated['unit_price'])
            ? (float) $validated['unit_price']
            : ($existing?->unit_price);

        if ($quantity === null || $unitPrice === null) {
            return $validated;
        }

        $validated['total_value'] = round($quantity * $unitPrice, 2);
        return $validated;
    }
}
