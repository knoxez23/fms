<?php

namespace App\Services\Audit;

use App\Models\AuditEvent;
use Illuminate\Database\Eloquent\Collection;

class AuditEventService
{
    public function record(
        int $userId,
        string $eventType,
        string $entityType,
        ?string $entityId = null,
        array $metadata = []
    ): AuditEvent {
        return AuditEvent::create([
            'user_id' => $userId,
            'event_type' => $eventType,
            'entity_type' => $entityType,
            'entity_id' => $entityId,
            'metadata' => $metadata,
            'occurred_at' => now(),
        ]);
    }

    public function listForUser(int $userId, int $limit = 100): Collection
    {
        return AuditEvent::where('user_id', $userId)
            ->orderByDesc('occurred_at')
            ->limit(max(1, min($limit, 500)))
            ->get();
    }
}
