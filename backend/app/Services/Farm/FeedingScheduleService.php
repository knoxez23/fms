<?php

namespace App\Services\Farm;

use App\Models\Animal;
use App\Models\FeedingSchedule;
use App\Models\Inventory;
use App\Models\User;
use App\Services\Audit\AuditEventService;
use Illuminate\Support\Collection;
use Illuminate\Validation\ValidationException;

class FeedingScheduleService
{
    public function __construct(private readonly AuditEventService $auditService)
    {
    }

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
        $animal = $this->findOwnedAnimal($user, (int) $validated['animal_id']);
        $this->validateOwnedInventoryAndUnit($user, $validated);
        $schedule = FeedingSchedule::create($validated);

        $this->auditService->record(
            userId: $user->id,
            eventType: 'feeding_schedule.created',
            entityType: 'feeding_schedule',
            entityId: (string) $schedule->id,
            metadata: [
                'animal_name' => $animal->name,
                'feed_type' => $schedule->feed_type,
                'quantity' => $schedule->quantity,
                'unit' => $schedule->unit,
                'time_of_day' => $schedule->time_of_day,
                'summary' => "Created {$schedule->time_of_day} feeding schedule for {$animal->name}.",
            ]
        );

        return $schedule;
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

        $animal = $this->findOwnedAnimal($user, (int) $feedingSchedule->animal_id);
        $this->auditService->record(
            userId: $user->id,
            eventType: 'feeding_schedule.updated',
            entityType: 'feeding_schedule',
            entityId: (string) $feedingSchedule->id,
            metadata: [
                'animal_name' => $animal->name,
                'feed_type' => $feedingSchedule->feed_type,
                'time_of_day' => $feedingSchedule->time_of_day,
                'changed_fields' => array_keys($validated),
                'summary' => "Updated feeding schedule for {$animal->name}.",
            ]
        );

        return $feedingSchedule;
    }

    public function deleteForUser(User $user, string $id): void
    {
        $feedingSchedule = FeedingSchedule::findOrFail($id);
        $animal = $this->findOwnedAnimal($user, (int) $feedingSchedule->animal_id);
        $scheduleRef = (string) $feedingSchedule->id;
        $timeOfDay = $feedingSchedule->time_of_day;
        $feedType = $feedingSchedule->feed_type;
        $feedingSchedule->delete();

        $this->auditService->record(
            userId: $user->id,
            eventType: 'feeding_schedule.deleted',
            entityType: 'feeding_schedule',
            entityId: $scheduleRef,
            metadata: [
                'animal_name' => $animal->name,
                'feed_type' => $feedType,
                'time_of_day' => $timeOfDay,
                'summary' => "Deleted {$timeOfDay} feeding schedule for {$animal->name}.",
            ]
        );
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
