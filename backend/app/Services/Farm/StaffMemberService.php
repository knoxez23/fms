<?php

namespace App\Services\Farm;

use App\Models\StaffMember;
use App\Services\Audit\AuditEventService;
use Illuminate\Support\Collection;

class StaffMemberService
{
    public function __construct(
        private readonly AuditEventService $auditService,
        private readonly FarmContextService $farmContextService,
    )
    {
    }

    /**
     * @return Collection<int, StaffMember>
     */
    public function listForUser(int $userId): Collection
    {
        $farmId = $this->farmContextService->requireCurrentFarm($userId)->id;

        return StaffMember::where('user_id', $userId)
            ->where(function ($query) use ($farmId, $userId) {
                $query->where('farm_id', $farmId)
                    ->orWhere(function ($legacy) use ($userId) {
                        $legacy->whereNull('farm_id')
                            ->where('user_id', $userId);
                    });
            })
            ->orderBy('name')
            ->get();
    }

    public function createForUser(int $userId, array $validated): StaffMember
    {
        $farm = $this->farmContextService->requireCurrentFarm($userId);
        $staffMember = StaffMember::create(array_merge($validated, [
            'user_id' => $userId,
            'farm_id' => $farm->id,
            'employment_status' => $validated['employment_status'] ?? 'active',
            'can_login' => (bool) ($validated['can_login'] ?? false),
        ]));

        $this->auditService->record(
            userId: $userId,
            eventType: 'staff.created',
            entityType: 'staff_member',
            entityId: (string) $staffMember->id,
            metadata: [
                'name' => $staffMember->name,
                'role' => $staffMember->role,
                'employment_status' => $staffMember->employment_status,
                'assignment_area' => $staffMember->assignment_area,
                'farm_name' => $farm->name,
                'summary' => "Added staff member {$staffMember->name}" . ($staffMember->role ? " ({$staffMember->role})" : '') . " to {$farm->name}.",
            ]
        );

        return $staffMember;
    }

    public function showForUser(int $userId, string $id): StaffMember
    {
        $farmId = $this->farmContextService->requireCurrentFarm($userId)->id;

        return StaffMember::where('user_id', $userId)
            ->where(function ($query) use ($farmId, $userId) {
                $query->where('farm_id', $farmId)
                    ->orWhere(function ($legacy) use ($userId) {
                        $legacy->whereNull('farm_id')
                            ->where('user_id', $userId);
                    });
            })
            ->where('id', $id)
            ->firstOrFail();
    }

    public function updateForUser(int $userId, string $id, array $validated): StaffMember
    {
        $staffMember = $this->showForUser($userId, $id);
        $staffMember->update($validated);

        $this->auditService->record(
            userId: $userId,
            eventType: 'staff.updated',
            entityType: 'staff_member',
            entityId: (string) $staffMember->id,
            metadata: [
                'name' => $staffMember->name,
                'role' => $staffMember->role,
                'employment_status' => $staffMember->employment_status,
                'assignment_area' => $staffMember->assignment_area,
                'changed_fields' => array_keys($validated),
                'summary' => "Updated staff member {$staffMember->name}.",
            ]
        );

        return $staffMember;
    }

    public function deleteForUser(int $userId, string $id): void
    {
        $staffMember = $this->showForUser($userId, $id);
        $staffRef = (string) $staffMember->id;
        $name = $staffMember->name;
        $role = $staffMember->role;
        $staffMember->delete();

        $this->auditService->record(
            userId: $userId,
            eventType: 'staff.deleted',
            entityType: 'staff_member',
            entityId: $staffRef,
            metadata: [
                'name' => $name,
                'role' => $role,
                'employment_status' => $staffMember->employment_status,
                'summary' => "Deleted staff member {$name}.",
            ]
        );
    }
}
