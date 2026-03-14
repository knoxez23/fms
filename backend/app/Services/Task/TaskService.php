<?php

namespace App\Services\Task;

use App\Models\StaffMember;
use App\Models\Task;
use App\Services\Audit\AuditEventService;
use Illuminate\Support\Collection;

class TaskService
{
    public function __construct(private readonly AuditEventService $auditService)
    {
    }

    /**
     * @return Collection<int, Task>
     */
    public function listForUser(int $userId): Collection
    {
        return Task::where('user_id', $userId)->get();
    }

    public function createForUser(int $userId, array $validated): Task
    {
        $validated = $this->attachOwnedStaffName($userId, $validated);
        $clientUuid = $validated['client_uuid'] ?? null;

        if (is_string($clientUuid) && $clientUuid !== '') {
            $existing = Task::where('user_id', $userId)
                ->where('client_uuid', $clientUuid)
                ->first();

            if ($existing !== null) {
                $existing->fill($validated);
                $existing->save();

                $this->auditService->record(
                    userId: $userId,
                    eventType: 'task.upserted',
                    entityType: 'task',
                    entityId: (string) $existing->id,
                    metadata: [
                        'title' => $existing->title,
                        'source_event_type' => $existing->source_event_type,
                        'source_event_id' => $existing->source_event_id,
                        'changed_fields' => array_keys($validated),
                        'summary' => "Upserted task {$existing->title}.",
                    ]
                );

                return $existing;
            }
        }

        $task = Task::create(array_merge($validated, ['user_id' => $userId]));

        $this->auditService->record(
            userId: $userId,
            eventType: 'task.created',
            entityType: 'task',
            entityId: (string) $task->id,
            metadata: [
                'title' => $task->title,
                'source_event_type' => $task->source_event_type,
                'source_event_id' => $task->source_event_id,
            ]
        );

        return $task;
    }

    public function updateForUser(int $userId, string $taskId, array $validated): Task
    {
        $validated = $this->attachOwnedStaffName($userId, $validated);
        $task = Task::where('id', $taskId)->where('user_id', $userId)->firstOrFail();
        $task->update($validated);

        $this->auditService->record(
            userId: $userId,
            eventType: 'task.updated',
            entityType: 'task',
            entityId: (string) $task->id,
            metadata: [
                'status' => $task->status,
                'source_event_type' => $task->source_event_type,
                'source_event_id' => $task->source_event_id,
            ]
        );

        return $task;
    }

    public function showForUser(int $userId, string $taskId): Task
    {
        return Task::where('id', $taskId)->where('user_id', $userId)->firstOrFail();
    }

    public function deleteForUser(int $userId, string $taskId): void
    {
        $task = Task::where('id', $taskId)->where('user_id', $userId)->firstOrFail();
        $taskRef = (string) $task->id;
        $task->delete();

        $this->auditService->record(
            userId: $userId,
            eventType: 'task.deleted',
            entityType: 'task',
            entityId: $taskRef,
        );
    }

    private function attachOwnedStaffName(int $userId, array $validated): array
    {
        if (! isset($validated['staff_member_id'])) {
            return $validated;
        }

        $staff = StaffMember::where('user_id', $userId)
            ->where('id', $validated['staff_member_id'])
            ->firstOrFail();

        if (! isset($validated['assigned_to']) || empty(trim((string) $validated['assigned_to']))) {
            $validated['assigned_to'] = $staff->name;
        }

        return $validated;
    }
}
