<?php

namespace App\Services\Farm;

use App\Models\Animal;
use App\Models\FeedingLog;
use App\Models\User;
use Illuminate\Support\Collection;

class FeedingLogService
{
    /**
     * @return Collection<int, FeedingLog>
     */
    public function listForUser(User $user): Collection
    {
        $animalIds = $user->animals()->pluck('id');
        return FeedingLog::whereIn('animal_id', $animalIds)->get();
    }

    public function createForUser(User $user, array $validated): FeedingLog
    {
        $this->findOwnedAnimal($user, (int) $validated['animal_id']);
        return FeedingLog::create($validated);
    }

    public function showForUser(User $user, string $id): FeedingLog
    {
        $feedingLog = FeedingLog::findOrFail($id);
        $this->findOwnedAnimal($user, (int) $feedingLog->animal_id);
        return $feedingLog;
    }

    public function updateForUser(User $user, string $id, array $validated): FeedingLog
    {
        $feedingLog = FeedingLog::findOrFail($id);
        $this->findOwnedAnimal($user, (int) $feedingLog->animal_id);

        if (isset($validated['animal_id'])) {
            $this->findOwnedAnimal($user, (int) $validated['animal_id']);
        }

        $feedingLog->update($validated);
        return $feedingLog;
    }

    public function deleteForUser(User $user, string $id): void
    {
        $feedingLog = FeedingLog::findOrFail($id);
        $this->findOwnedAnimal($user, (int) $feedingLog->animal_id);
        $feedingLog->delete();
    }

    private function findOwnedAnimal(User $user, int $animalId): Animal
    {
        return $user->animals()->where('id', $animalId)->firstOrFail();
    }
}
