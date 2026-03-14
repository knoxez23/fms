<?php

namespace App\Services\Farm;

use App\Models\Animal;
use App\Models\AnimalProductionLog;
use App\Models\User;
use App\Services\Audit\AuditEventService;
use Illuminate\Support\Collection;

class AnimalProductionLogService
{
    public function __construct(private readonly AuditEventService $auditService)
    {
    }

    /**
     * @return Collection<int, AnimalProductionLog>
     */
    public function listForUser(int $userId): Collection
    {
        return AnimalProductionLog::where('user_id', $userId)->with('animal')->get();
    }

    public function createForUser(User $user, array $validated): AnimalProductionLog
    {
        $animal = $this->findOwnedAnimal($user, (int) $validated['animal_id']);

        $record = AnimalProductionLog::create(array_merge($validated, [
            'user_id' => $user->id,
        ]));

        $this->auditService->record(
            userId: $user->id,
            eventType: 'animal_production.created',
            entityType: 'animal_production_log',
            entityId: (string) $record->id,
            metadata: [
                'animal_name' => $animal->name,
                'type' => $record->type,
                'quantity' => $record->quantity,
                'unit' => $record->unit,
                'summary' => "Logged {$record->type} production for {$animal->name}.",
            ]
        );

        return $record;
    }

    public function updateForUser(User $user, string $id, array $validated): AnimalProductionLog
    {
        $record = AnimalProductionLog::where('id', $id)->where('user_id', $user->id)->firstOrFail();

        if (isset($validated['animal_id'])) {
            $this->findOwnedAnimal($user, (int) $validated['animal_id']);
        }

        $record->update($validated);

        $animal = $this->findOwnedAnimal($user, (int) $record->animal_id);
        $this->auditService->record(
            userId: $user->id,
            eventType: 'animal_production.updated',
            entityType: 'animal_production_log',
            entityId: (string) $record->id,
            metadata: [
                'animal_name' => $animal->name,
                'type' => $record->type,
                'quantity' => $record->quantity,
                'unit' => $record->unit,
                'changed_fields' => array_keys($validated),
                'summary' => "Updated {$record->type} production for {$animal->name}.",
            ]
        );

        return $record;
    }

    public function deleteForUser(int $userId, string $id): void
    {
        $record = AnimalProductionLog::where('id', $id)->where('user_id', $userId)->firstOrFail();
        $recordRef = (string) $record->id;
        $animalName = optional($record->animal)->name;
        $type = $record->type;
        $quantity = $record->quantity;
        $unit = $record->unit;
        $record->delete();

        $this->auditService->record(
            userId: $userId,
            eventType: 'animal_production.deleted',
            entityType: 'animal_production_log',
            entityId: $recordRef,
            metadata: [
                'animal_name' => $animalName,
                'type' => $type,
                'quantity' => $quantity,
                'unit' => $unit,
                'summary' => "Deleted {$type} production log.",
            ]
        );
    }

    private function findOwnedAnimal(User $user, int $animalId): Animal
    {
        return $user->animals()->where('id', $animalId)->firstOrFail();
    }
}
