<?php

namespace App\Services\Farm;

use App\Models\Animal;
use App\Models\FeedingLog;
use App\Models\Inventory;
use App\Models\User;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

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
        return DB::transaction(function () use ($user, $validated): FeedingLog {
            $inventory = $this->resolveOwnedInventory($user, $validated['inventory_id'] ?? null);
            if ($inventory !== null) {
                $this->consumeInventory(
                    $inventory,
                    quantity: (float) $validated['quantity'],
                    unit: (string) $validated['unit'],
                );
            }

            return FeedingLog::create($validated);
        });
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

        return DB::transaction(function () use ($feedingLog, $user, $validated): FeedingLog {
            $existingInventory = $this->resolveOwnedInventory($user, $feedingLog->inventory_id);
            if ($existingInventory !== null) {
                $this->restoreInventory(
                    $existingInventory,
                    quantity: (float) $feedingLog->quantity,
                    unit: (string) $feedingLog->unit,
                );
            }

            $nextInventoryId = array_key_exists('inventory_id', $validated)
                ? $validated['inventory_id']
                : $feedingLog->inventory_id;
            $nextQuantity = array_key_exists('quantity', $validated)
                ? (float) $validated['quantity']
                : (float) $feedingLog->quantity;
            $nextUnit = array_key_exists('unit', $validated)
                ? (string) $validated['unit']
                : (string) $feedingLog->unit;

            $nextInventory = $this->resolveOwnedInventory($user, $nextInventoryId);
            if ($nextInventory !== null) {
                $this->consumeInventory(
                    $nextInventory,
                    quantity: $nextQuantity,
                    unit: $nextUnit,
                );
            }

            $feedingLog->update($validated);
            return $feedingLog->fresh();
        });
    }

    public function deleteForUser(User $user, string $id): void
    {
        $feedingLog = FeedingLog::findOrFail($id);
        $this->findOwnedAnimal($user, (int) $feedingLog->animal_id);
        DB::transaction(function () use ($feedingLog, $user): void {
            $inventory = $this->resolveOwnedInventory($user, $feedingLog->inventory_id);
            if ($inventory !== null) {
                $this->restoreInventory(
                    $inventory,
                    quantity: (float) $feedingLog->quantity,
                    unit: (string) $feedingLog->unit,
                );
            }
            $feedingLog->delete();
        });
    }

    private function findOwnedAnimal(User $user, int $animalId): Animal
    {
        return $user->animals()->where('id', $animalId)->firstOrFail();
    }

    private function resolveOwnedInventory(User $user, mixed $inventoryId): ?Inventory
    {
        if ($inventoryId === null || $inventoryId === '') {
            return null;
        }

        return Inventory::where('id', (int) $inventoryId)
            ->where('user_id', $user->id)
            ->lockForUpdate()
            ->firstOrFail();
    }

    private function consumeInventory(Inventory $inventory, float $quantity, string $unit): void
    {
        $this->assertUnitMatches($inventory, $unit);

        if ($quantity <= 0) {
            throw ValidationException::withMessages([
                'quantity' => ['Quantity must be greater than zero.'],
            ]);
        }

        $current = (float) $inventory->quantity;
        if ($current < $quantity) {
            throw ValidationException::withMessages([
                'inventory_id' => [
                    "Insufficient stock for {$inventory->item_name}. Available: {$current} {$inventory->unit}.",
                ],
            ]);
        }

        $inventory->quantity = round($current - $quantity, 2);
        if ($inventory->unit_price !== null) {
            $inventory->total_value = round(((float) $inventory->unit_price) * $inventory->quantity, 2);
        }
        $inventory->save();
    }

    private function restoreInventory(Inventory $inventory, float $quantity, string $unit): void
    {
        $this->assertUnitMatches($inventory, $unit);

        if ($quantity <= 0) {
            return;
        }

        $inventory->quantity = round(((float) $inventory->quantity) + $quantity, 2);
        if ($inventory->unit_price !== null) {
            $inventory->total_value = round(((float) $inventory->unit_price) * $inventory->quantity, 2);
        }
        $inventory->save();
    }

    private function assertUnitMatches(Inventory $inventory, string $requestedUnit): void
    {
        if (strtolower(trim($inventory->unit)) === strtolower(trim($requestedUnit))) {
            return;
        }

        throw ValidationException::withMessages([
            'unit' => [
                "Unit mismatch. Inventory '{$inventory->item_name}' uses {$inventory->unit}.",
            ],
        ]);
    }
}
