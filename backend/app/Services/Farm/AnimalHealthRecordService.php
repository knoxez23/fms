<?php

namespace App\Services\Farm;

use App\Models\Animal;
use App\Models\AnimalHealthRecord;
use App\Models\User;
use Illuminate\Support\Collection;

class AnimalHealthRecordService
{
    /**
     * @return Collection<int, AnimalHealthRecord>
     */
    public function listForUser(int $userId): Collection
    {
        return AnimalHealthRecord::where('user_id', $userId)->with('animal')->get();
    }

    public function createForUser(User $user, array $validated): AnimalHealthRecord
    {
        $this->findOwnedAnimal($user, (int) $validated['animal_id']);

        return AnimalHealthRecord::create(array_merge($validated, [
            'user_id' => $user->id,
        ]));
    }

    public function updateForUser(User $user, string $id, array $validated): AnimalHealthRecord
    {
        $record = AnimalHealthRecord::where('id', $id)->where('user_id', $user->id)->firstOrFail();

        if (isset($validated['animal_id'])) {
            $this->findOwnedAnimal($user, (int) $validated['animal_id']);
        }

        $record->update($validated);
        return $record;
    }

    public function deleteForUser(int $userId, string $id): void
    {
        $record = AnimalHealthRecord::where('id', $id)->where('user_id', $userId)->firstOrFail();
        $record->delete();
    }

    private function findOwnedAnimal(User $user, int $animalId): Animal
    {
        return $user->animals()->where('id', $animalId)->firstOrFail();
    }
}
