<?php

namespace App\Services\Farm;

use App\Models\Animal;
use App\Models\FeedingSchedule;
use App\Models\Inventory;
use App\Models\User;
use Illuminate\Support\Collection;
use Illuminate\Validation\ValidationException;

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
        $this->validateOwnedInventoryAndUnit($user, $validated);
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

        $this->validateOwnedInventoryAndUnit($user, $validated, $feedingSchedule);
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

    private function validateOwnedInventoryAndUnit(
        User $user,
        array $validated,
        ?FeedingSchedule $current = null
    ): void {
        $inventoryId = array_key_exists('inventory_id', $validated)
            ? $validated['inventory_id']
            : $current?->inventory_id;
        if ($inventoryId === null || $inventoryId === '') {
            return;
        }

        $inventory = Inventory::where('id', (int) $inventoryId)
            ->where('user_id', $user->id)
            ->firstOrFail();
        $unit = array_key_exists('unit', $validated)
            ? (string) $validated['unit']
            : (string) ($current?->unit ?? '');

        if (strtolower(trim($inventory->unit)) === strtolower(trim($unit))) {
            return;
        }

        throw ValidationException::withMessages([
            'unit' => [
                "Unit mismatch. Inventory '{$inventory->item_name}' uses {$inventory->unit}.",
            ],
        ]);
    }
}
