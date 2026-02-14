<?php

namespace App\Services\Farm;

use App\Models\Animal;
use App\Models\AnimalWeight;
use App\Models\User;
use Illuminate\Pagination\LengthAwarePaginator;

class AnimalWeightService
{
    public function listForUser(int $userId, ?string $animalId, int $perPage): LengthAwarePaginator
    {
        $query = AnimalWeight::where('user_id', $userId)->with('animal');

        if ($animalId !== null) {
            $query->where('animal_id', $animalId);
        }

        return $query->orderBy('recorded_at', 'desc')->paginate($perPage);
    }

    public function createForUser(User $user, array $validated): AnimalWeight
    {
        $this->findOwnedAnimal($user, (int) $validated['animal_id']);

        return AnimalWeight::create(array_merge($validated, [
            'user_id' => $user->id,
        ]));
    }

    public function updateForUser(User $user, string $id, array $validated): AnimalWeight
    {
        $record = AnimalWeight::where('id', $id)->where('user_id', $user->id)->firstOrFail();

        if (isset($validated['animal_id'])) {
            $this->findOwnedAnimal($user, (int) $validated['animal_id']);
        }

        $record->update($validated);
        return $record;
    }

    public function deleteForUser(int $userId, string $id): void
    {
        $record = AnimalWeight::where('id', $id)->where('user_id', $userId)->firstOrFail();
        $record->delete();
    }

    private function findOwnedAnimal(User $user, int $animalId): Animal
    {
        return $user->animals()->where('id', $animalId)->firstOrFail();
    }
}
