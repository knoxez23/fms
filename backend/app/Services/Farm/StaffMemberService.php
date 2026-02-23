<?php

namespace App\Services\Farm;

use App\Models\StaffMember;
use Illuminate\Support\Collection;

class StaffMemberService
{
    /**
     * @return Collection<int, StaffMember>
     */
    public function listForUser(int $userId): Collection
    {
        return StaffMember::where('user_id', $userId)->orderBy('name')->get();
    }

    public function createForUser(int $userId, array $validated): StaffMember
    {
        return StaffMember::create(array_merge($validated, ['user_id' => $userId]));
    }

    public function showForUser(int $userId, string $id): StaffMember
    {
        return StaffMember::where('user_id', $userId)->where('id', $id)->firstOrFail();
    }

    public function updateForUser(int $userId, string $id, array $validated): StaffMember
    {
        $staffMember = $this->showForUser($userId, $id);
        $staffMember->update($validated);

        return $staffMember;
    }

    public function deleteForUser(int $userId, string $id): void
    {
        $staffMember = $this->showForUser($userId, $id);
        $staffMember->delete();
    }
}
