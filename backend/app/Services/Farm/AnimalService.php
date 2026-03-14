<?php

namespace App\Services\Farm;

use App\Models\Animal;
use App\Services\Audit\AuditEventService;
use Illuminate\Support\Collection;

class AnimalService
{
    public function __construct(private readonly AuditEventService $auditService)
    {
    }

    /**
     * @return Collection<int, Animal>
     */
    public function listForUser(int $userId): Collection
    {
        return Animal::where('user_id', $userId)->get();
    }

    public function createForUser(int $userId, array $validated): Animal
    {
        $animal = Animal::create(array_merge($validated, ['user_id' => $userId]));

        $this->auditService->record(
            userId: $userId,
            eventType: 'animal.created',
            entityType: 'animal',
            entityId: (string) $animal->id,
            metadata: [
                'name' => $animal->name,
                'type' => $animal->type,
                'breed' => $animal->breed,
                'summary' => "Added animal {$animal->name} ({$animal->type}).",
            ]
        );

        return $animal;
    }

    public function updateForUser(int $userId, string $animalId, array $validated): Animal
    {
        $animal = Animal::where('id', $animalId)->where('user_id', $userId)->firstOrFail();
        $animal->update($validated);

        $this->auditService->record(
            userId: $userId,
            eventType: 'animal.updated',
            entityType: 'animal',
            entityId: (string) $animal->id,
            metadata: [
                'name' => $animal->name,
                'type' => $animal->type,
                'changed_fields' => array_keys($validated),
                'summary' => "Updated animal {$animal->name}.",
            ]
        );

        return $animal;
    }

    public function showForUser(int $userId, string $animalId): Animal
    {
        return Animal::where('id', $animalId)->where('user_id', $userId)->firstOrFail();
    }

    public function deleteForUser(int $userId, string $animalId): void
    {
        $animal = Animal::where('id', $animalId)->where('user_id', $userId)->firstOrFail();
        $animalRef = (string) $animal->id;
        $name = $animal->name;
        $type = $animal->type;
        $animal->delete();

        $this->auditService->record(
            userId: $userId,
            eventType: 'animal.deleted',
            entityType: 'animal',
            entityId: $animalRef,
            metadata: [
                'name' => $name,
                'type' => $type,
                'summary' => "Deleted animal {$name} ({$type}).",
            ]
        );
    }
}
