<?php

namespace App\Services\Farm;

use App\Models\Farm;
use App\Models\FarmMembership;
use App\Models\User;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Support\Collection;

class FarmContextService
{
    public function getDefaultMembership(int $userId): ?FarmMembership
    {
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
}
