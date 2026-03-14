<?php

namespace App\Services\Farm;

use App\Models\Customer;
use App\Services\Audit\AuditEventService;
use Illuminate\Support\Collection;

class CustomerService
{
    public function __construct(
        private readonly AuditEventService $auditService,
        private readonly FarmContextService $farmContextService,
    )
    {
    }

    /**
     * @return Collection<int, Customer>
     */
    public function listForUser(int $userId): Collection
    {
        return Customer::where('user_id', $userId)->orderBy('name')->get();
    }

    public function createForUser(int $userId, array $validated): Customer
    {
        $this->farmContextService->assertCanManageCommercialOps($userId);
        $customer = Customer::create(array_merge($validated, ['user_id' => $userId]));

        $this->auditService->record(
            userId: $userId,
            eventType: 'customer.created',
            entityType: 'customer',
            entityId: (string) $customer->id,
            metadata: [
                'name' => $customer->name,
                'summary' => "Added customer {$customer->name}.",
            ]
        );

        return $customer;
    }

    public function showForUser(int $userId, string $id): Customer
    {
        return Customer::where('user_id', $userId)->where('id', $id)->firstOrFail();
    }

    public function updateForUser(int $userId, string $id, array $validated): Customer
    {
        $this->farmContextService->assertCanManageCommercialOps($userId);
        $customer = $this->showForUser($userId, $id);
        $customer->update($validated);

        $this->auditService->record(
            userId: $userId,
            eventType: 'customer.updated',
            entityType: 'customer',
            entityId: (string) $customer->id,
            metadata: [
                'name' => $customer->name,
                'changed_fields' => array_keys($validated),
                'summary' => "Updated customer {$customer->name}.",
            ]
        );

        return $customer;
    }

    public function deleteForUser(int $userId, string $id): void
    {
        $this->farmContextService->assertCanManageCommercialOps($userId);
        $customer = $this->showForUser($userId, $id);
        $customerRef = (string) $customer->id;
        $name = $customer->name;
        $customer->delete();

        $this->auditService->record(
            userId: $userId,
            eventType: 'customer.deleted',
            entityType: 'customer',
            entityId: $customerRef,
            metadata: [
                'name' => $name,
                'summary' => "Deleted customer {$name}.",
            ]
        );
    }
}
