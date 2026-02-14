<?php

namespace App\Services\Farm;

use App\Models\Animal;
use Illuminate\Support\Collection;

class AnimalService
{
    /**
     * @return Collection<int, Animal>
     */
    public function listForUser(int $userId): Collection
    {
        return Animal::where('user_id', $userId)->get();
    }

    public function createForUser(int $userId, array $validated): Animal
    {
        return Animal::create(array_merge($validated, ['user_id' => $userId]));
    }

    public function updateForUser(int $userId, string $animalId, array $validated): Animal
    {
        $animal = Animal::where('id', $animalId)->where('user_id', $userId)->firstOrFail();
        $animal->update($validated);
        return $animal;
    }

    public function showForUser(int $userId, string $animalId): Animal
    {
        return Animal::where('id', $animalId)->where('user_id', $userId)->firstOrFail();
    }

    public function deleteForUser(int $userId, string $animalId): void
    {
        $animal = Animal::where('id', $animalId)->where('user_id', $userId)->firstOrFail();
        $animal->delete();
    }
}
