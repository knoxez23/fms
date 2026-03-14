<?php

namespace App\Services\Farm;

use App\Models\Crop;
use App\Services\Audit\AuditEventService;
use Illuminate\Support\Collection;

class CropService
{
    public function __construct(private readonly AuditEventService $auditService)
    {
    }

    /**
     * @return Collection<int, Crop>
     */
    public function listForUser(int $userId): Collection
    {
        return Crop::where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->get();
    }

    public function createForUser(int $userId, array $validated): Crop
    {
        $crop = Crop::create(array_merge($validated, ['user_id' => $userId]));

        $this->auditService->record(
            userId: $userId,
            eventType: 'crop.created',
            entityType: 'crop',
            entityId: (string) $crop->id,
            metadata: [
                'name' => $crop->name,
                'status' => $crop->status,
                'area' => $crop->area,
                'summary' => "Added crop {$crop->name} with status {$crop->status}.",
            ]
        );

        return $crop;
    }

    public function updateForUser(int $userId, string $cropId, array $validated): Crop
    {
        $crop = Crop::where('id', $cropId)
            ->where('user_id', $userId)
            ->firstOrFail();

        $crop->update($validated);

        $this->auditService->record(
            userId: $userId,
            eventType: 'crop.updated',
            entityType: 'crop',
            entityId: (string) $crop->id,
            metadata: [
                'name' => $crop->name,
                'status' => $crop->status,
                'changed_fields' => array_keys($validated),
                'summary' => "Updated crop {$crop->name}.",
            ]
        );

        return $crop;
    }

    public function showForUser(int $userId, string $cropId): Crop
    {
        return Crop::where('id', $cropId)
            ->where('user_id', $userId)
            ->firstOrFail();
    }

    public function deleteForUser(int $userId, string $cropId): void
    {
        $crop = Crop::where('id', $cropId)
            ->where('user_id', $userId)
            ->firstOrFail();
        $cropRef = (string) $crop->id;
        $name = $crop->name;
        $status = $crop->status;
        $crop->delete();

        $this->auditService->record(
            userId: $userId,
            eventType: 'crop.deleted',
            entityType: 'crop',
            entityId: $cropRef,
            metadata: [
                'name' => $name,
                'status' => $status,
                'summary' => "Deleted crop {$name}.",
            ]
        );
    }
}
