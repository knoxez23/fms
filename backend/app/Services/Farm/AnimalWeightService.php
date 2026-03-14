<?php

namespace App\Services\Farm;

use App\Models\Animal;
use App\Models\AnimalWeight;
use App\Models\User;
use App\Services\Audit\AuditEventService;
use Illuminate\Pagination\LengthAwarePaginator;

class AnimalWeightService
{
    public function __construct(private readonly AuditEventService $auditService)
    {
    }

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
        $animal = $this->findOwnedAnimal($user, (int) $validated['animal_id']);

        $record = AnimalWeight::create(array_merge($validated, [
            'user_id' => $user->id,
        ]));

        $this->auditService->record(
            userId: $user->id,
            eventType: 'animal_weight.created',
            entityType: 'animal_weight',
            entityId: (string) $record->id,
            metadata: [
                'animal_name' => $animal->name,
                'weight' => $record->weight,
                'summary' => "Recorded weight for {$animal->name}: {$record->weight}.",
            ]
        );

        return $record;
    }

    public function updateForUser(User $user, string $id, array $validated): AnimalWeight
    {
        $record = AnimalWeight::where('id', $id)->where('user_id', $user->id)->firstOrFail();

        if (isset($validated['animal_id'])) {
            $this->findOwnedAnimal($user, (int) $validated['animal_id']);
        }

        $record->update($validated);

        $animal = $this->findOwnedAnimal($user, (int) $record->animal_id);
        $this->auditService->record(
            userId: $user->id,
            eventType: 'animal_weight.updated',
            entityType: 'animal_weight',
            entityId: (string) $record->id,
            metadata: [
                'animal_name' => $animal->name,
                'weight' => $record->weight,
                'changed_fields' => array_keys($validated),
                'summary' => "Updated weight record for {$animal->name}.",
            ]
        );

        return $record;
    }

    public function deleteForUser(int $userId, string $id): void
    {
        $record = AnimalWeight::where('id', $id)->where('user_id', $userId)->firstOrFail();
        $recordRef = (string) $record->id;
        $weight = $record->weight;
        $animalName = optional($record->animal)->name;
        $record->delete();

        $this->auditService->record(
            userId: $userId,
            eventType: 'animal_weight.deleted',
            entityType: 'animal_weight',
            entityId: $recordRef,
            metadata: [
                'animal_name' => $animalName,
                'weight' => $weight,
                'summary' => "Deleted weight record" . ($animalName ? " for {$animalName}" : '') . '.',
            ]
        );
    }

    private function findOwnedAnimal(User $user, int $animalId): Animal
    {
        return $user->animals()->where('id', $animalId)->firstOrFail();
    }
}
