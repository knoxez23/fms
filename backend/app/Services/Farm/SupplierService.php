<?php

namespace App\Services\Farm;

use App\Models\Supplier;
use App\Services\Audit\AuditEventService;
use Illuminate\Support\Collection;

class SupplierService
{
    public function __construct(private readonly AuditEventService $auditService)
    {
    }

    /**
     * @return Collection<int, Supplier>
     */
    public function listForUser(int $userId): Collection
    {
        return Supplier::where('user_id', $userId)->orderBy('name')->get();
    }

    public function createForUser(int $userId, array $validated): Supplier
    {
        $supplier = Supplier::create(array_merge($validated, ['user_id' => $userId]));

        $this->auditService->record(
            userId: $userId,
            eventType: 'supplier.created',
            entityType: 'supplier',
            entityId: (string) $supplier->id,
            metadata: [
                'name' => $supplier->name,
                'summary' => "Added supplier {$supplier->name}.",
            ]
        );

        return $supplier;
    }

    public function showForUser(int $userId, string $id): Supplier
    {
        return Supplier::where('user_id', $userId)->where('id', $id)->firstOrFail();
    }

    public function updateForUser(int $userId, string $id, array $validated): Supplier
    {
        $supplier = $this->showForUser($userId, $id);
        $supplier->update($validated);

        $this->auditService->record(
            userId: $userId,
            eventType: 'supplier.updated',
            entityType: 'supplier',
            entityId: (string) $supplier->id,
            metadata: [
                'name' => $supplier->name,
                'changed_fields' => array_keys($validated),
                'summary' => "Updated supplier {$supplier->name}.",
            ]
        );

        return $supplier;
    }

    public function deleteForUser(int $userId, string $id): void
    {
        $supplier = $this->showForUser($userId, $id);
        $supplierRef = (string) $supplier->id;
        $name = $supplier->name;
        $supplier->delete();

        $this->auditService->record(
            userId: $userId,
            eventType: 'supplier.deleted',
            entityType: 'supplier',
            entityId: $supplierRef,
            metadata: [
                'name' => $name,
                'summary' => "Deleted supplier {$name}.",
            ]
        );
    }
}
