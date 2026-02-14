<?php

namespace App\Services\Farm;

use App\Models\Animal;
use App\Models\AnimalProductionLog;
use App\Models\User;
use Illuminate\Support\Collection;

class AnimalProductionLogService
{
    /**
     * @return Collection<int, AnimalProductionLog>
     */
    public function listForUser(int $userId): Collection
    {
        return AnimalProductionLog::where('user_id', $userId)->with('animal')->get();
    }

    public function createForUser(User $user, array $validated): AnimalProductionLog
    {
        $this->findOwnedAnimal($user, (int) $validated['animal_id']);

        return AnimalProductionLog::create(array_merge($validated, [
            'user_id' => $user->id,
        ]));
    }

    public function updateForUser(User $user, string $id, array $validated): AnimalProductionLog
    {
        $record = AnimalProductionLog::where('id', $id)->where('user_id', $user->id)->firstOrFail();

        if (isset($validated['animal_id'])) {
            $this->findOwnedAnimal($user, (int) $validated['animal_id']);
        }

        $record->update($validated);
        return $record;
    }

    public function deleteForUser(int $userId, string $id): void
    {
        $record = AnimalProductionLog::where('id', $id)->where('user_id', $userId)->firstOrFail();
        $record->delete();
    }

    private function findOwnedAnimal(User $user, int $animalId): Animal
    {
        return $user->animals()->where('id', $animalId)->firstOrFail();
    }
}
