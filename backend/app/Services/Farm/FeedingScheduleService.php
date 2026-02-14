<?php

namespace App\Services\Farm;

use App\Models\Animal;
use App\Models\FeedingSchedule;
use App\Models\User;
use Illuminate\Support\Collection;

class FeedingScheduleService
{
    /**
     * @return Collection<int, FeedingSchedule>
     */
    public function listForUser(User $user): Collection
    {
        $animalIds = $user->animals()->pluck('id');
        return FeedingSchedule::whereIn('animal_id', $animalIds)->get();
    }

    public function createForUser(User $user, array $validated): FeedingSchedule
    {
        $this->findOwnedAnimal($user, (int) $validated['animal_id']);
        return FeedingSchedule::create($validated);
    }

    public function showForUser(User $user, string $id): FeedingSchedule
    {
        $feedingSchedule = FeedingSchedule::findOrFail($id);
        $this->findOwnedAnimal($user, (int) $feedingSchedule->animal_id);
        return $feedingSchedule;
    }

    public function updateForUser(User $user, string $id, array $validated): FeedingSchedule
    {
        $feedingSchedule = FeedingSchedule::findOrFail($id);
        $this->findOwnedAnimal($user, (int) $feedingSchedule->animal_id);

        if (isset($validated['animal_id'])) {
            $this->findOwnedAnimal($user, (int) $validated['animal_id']);
        }

        $feedingSchedule->update($validated);
        return $feedingSchedule;
    }

    public function deleteForUser(User $user, string $id): void
    {
        $feedingSchedule = FeedingSchedule::findOrFail($id);
        $this->findOwnedAnimal($user, (int) $feedingSchedule->animal_id);
        $feedingSchedule->delete();
    }

    private function findOwnedAnimal(User $user, int $animalId): Animal
    {
        return $user->animals()->where('id', $animalId)->firstOrFail();
    }
}
