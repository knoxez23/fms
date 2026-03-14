<?php

namespace App\Services\Farm;

use App\Models\Animal;
use App\Models\AnimalHealthRecord;
use App\Models\User;
use App\Services\Audit\AuditEventService;
use Illuminate\Support\Collection;

class AnimalHealthRecordService
{
    public function __construct(private readonly AuditEventService $auditService)
    {
    }

    /**
     * @return Collection<int, AnimalHealthRecord>
     */
    public function listForUser(int $userId): Collection
    {
        return AnimalHealthRecord::where('user_id', $userId)->with('animal')->get();
    }

    public function createForUser(User $user, array $validated): AnimalHealthRecord
    {
        $animal = $this->findOwnedAnimal($user, (int) $validated['animal_id']);

        $record = AnimalHealthRecord::create(array_merge($validated, [
            'user_id' => $user->id,
        ]));

        $this->auditService->record(
            userId: $user->id,
            eventType: 'animal_health.created',
            entityType: 'animal_health_record',
            entityId: (string) $record->id,
            metadata: [
                'animal_name' => $animal->name,
                'type' => $record->type,
                'name' => $record->name,
                'summary' => "Added {$record->type} health record for {$animal->name}.",
            ]
        );

        return $record;
    }

    public function updateForUser(User $user, string $id, array $validated): AnimalHealthRecord
    {
        $record = AnimalHealthRecord::where('id', $id)->where('user_id', $user->id)->firstOrFail();

        if (isset($validated['animal_id'])) {
            $this->findOwnedAnimal($user, (int) $validated['animal_id']);
        }

        $record->update($validated);

        $animal = $this->findOwnedAnimal($user, (int) $record->animal_id);
        $this->auditService->record(
            userId: $user->id,
            eventType: 'animal_health.updated',
            entityType: 'animal_health_record',
            entityId: (string) $record->id,
            metadata: [
                'animal_name' => $animal->name,
                'type' => $record->type,
                'name' => $record->name,
                'changed_fields' => array_keys($validated),
                'summary' => "Updated health record for {$animal->name}.",
            ]
        );

        return $record;
    }

    public function deleteForUser(int $userId, string $id): void
    {
        $record = AnimalHealthRecord::where('id', $id)->where('user_id', $userId)->firstOrFail();
        $recordRef = (string) $record->id;
        $animalName = optional($record->animal)->name;
        $type = $record->type;
        $name = $record->name;
        $record->delete();

        $this->auditService->record(
            userId: $userId,
            eventType: 'animal_health.deleted',
            entityType: 'animal_health_record',
            entityId: $recordRef,
            metadata: [
                'animal_name' => $animalName,
                'type' => $type,
                'name' => $name,
                'summary' => "Deleted health record {$name}.",
            ]
        );
    }

    private function findOwnedAnimal(User $user, int $animalId): Animal
    {
        return $user->animals()->where('id', $animalId)->firstOrFail();
    }
}
