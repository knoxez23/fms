<?php

namespace App\Services\Farm;

use App\Models\Farm;
use App\Models\FarmMembership;
use App\Models\User;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Collection;

class FarmContextService
{
    public function schemaReady(): bool
    {
        return Schema::hasTable('farms') && Schema::hasTable('farm_memberships');
    }

    public function getDefaultMembership(int $userId): ?FarmMembership
    {
        if (! $this->schemaReady()) {
            return null;
        }

        return FarmMembership::query()
            ->with('farm')
            ->where('user_id', $userId)
            ->where('status', 'active')
            ->orderByDesc('is_default')
            ->orderBy('id')
            ->first();
    }

    public function requireDefaultMembership(int $userId): FarmMembership
    {
        if (! $this->schemaReady()) {
            throw (new ModelNotFoundException())->setModel(FarmMembership::class);
        }

        $membership = $this->getDefaultMembership($userId);
        if ($membership === null) {
            $user = User::query()->findOrFail($userId);
            $membership = $this->createDefaultFarmForUser($user);
        }

        if ($membership === null) {
            throw (new ModelNotFoundException())->setModel(FarmMembership::class);
        }

        return $membership;
    }

    public function requireCurrentFarm(int $userId): Farm
    {
        return $this->requireDefaultMembership($userId)->farm()->firstOrFail();
    }

    public function currentContext(int $userId): array
    {
        if (! $this->schemaReady()) {
            $user = User::query()->findOrFail($userId);

            return [
                'farm' => [
                    'id' => null,
                    'name' => filled($user->farm_name) ? $user->farm_name : trim($user->name . "'s Farm"),
                    'location' => $user->location,
                    'primary_enterprise' => null,
                    'feed_measurement_style' => null,
                ],
                'membership' => [
                    'id' => null,
                    'role' => 'owner',
                    'status' => 'legacy',
                    'is_default' => true,
                    'joined_at' => null,
                ],
                'team_summary' => [
                    'staff_count' => 0,
                    'active_staff_count' => 0,
                    'roles' => [],
                ],
            ];
        }

        $membership = $this->requireDefaultMembership($userId);
        $farm = $membership->farm()->firstOrFail();
        $staff = $farm->staffMembers()->orderBy('name')->get();

        return [
            'farm' => [
                'id' => $farm->id,
                'name' => $farm->name,
                'location' => $farm->location,
                'primary_enterprise' => $farm->primary_enterprise,
                'feed_measurement_style' => $farm->feed_measurement_style,
            ],
            'membership' => [
                'id' => $membership->id,
                'role' => $membership->role,
                'status' => $membership->status,
                'is_default' => (bool) $membership->is_default,
                'joined_at' => optional($membership->joined_at)?->toISOString(),
            ],
            'team_summary' => [
                'staff_count' => $staff->count(),
                'active_staff_count' => $staff->where('employment_status', 'active')->count(),
                'roles' => $staff
                    ->groupBy(fn ($item) => $item->role ?: 'Unassigned')
                    ->map(fn (Collection $group) => $group->count())
                    ->sortKeys()
                    ->all(),
            ],
        ];
    }

    public function createDefaultFarmForUser(User $user): FarmMembership
    {
        if (! $this->schemaReady()) {
            throw (new ModelNotFoundException())->setModel(FarmMembership::class);
        }

        $existing = $this->getDefaultMembership((int) $user->id);
        if ($existing !== null) {
            return $existing;
        }

        $farm = Farm::create([
            'owner_user_id' => $user->id,
            'name' => filled($user->farm_name) ? $user->farm_name : trim($user->name . "'s Farm"),
            'location' => $user->location,
            'profile' => [
                'seeded_from' => 'registration',
            ],
        ]);

        return FarmMembership::create([
            'farm_id' => $farm->id,
            'user_id' => $user->id,
            'role' => 'owner',
            'status' => 'active',
            'is_default' => true,
            'joined_at' => now(),
            'invited_by' => $user->id,
        ]);
    }

    public function roleForUser(int $userId): string
    {
        $membership = $this->getDefaultMembership($userId);

        return strtolower((string) ($membership?->role ?? 'owner'));
    }

    public function canManageTeam(int $userId): bool
    {
        return in_array($this->roleForUser($userId), ['owner', 'manager'], true);
    }

    public function canManageCommercialOps(int $userId): bool
    {
        return in_array($this->roleForUser($userId), ['owner', 'manager', 'accountant'], true);
    }

    public function canApproveTasks(int $userId): bool
    {
        return in_array($this->roleForUser($userId), ['owner', 'manager', 'accountant'], true);
    }

    public function assertCanManageTeam(int $userId): void
    {
        if (! $this->canManageTeam($userId)) {
            throw new AuthorizationException('Only owners or managers can manage farm team records.');
        }
    }

    public function assertCanManageCommercialOps(int $userId): void
    {
        if (! $this->canManageCommercialOps($userId)) {
            throw new AuthorizationException('Only owners, managers, or accountants can manage sales and commercial records.');
        }
    }
}
