<?php

namespace App\Services\Task;

use App\Models\StaffMember;
use App\Models\Task;
use App\Services\Audit\AuditEventService;
use App\Services\Farm\FarmContextService;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Support\Collection;

class TaskService
{
    public function __construct(
        private readonly AuditEventService $auditService,
        private readonly FarmContextService $farmContextService,
    )
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
        $validated = $this->normalizeApprovalFields($userId, $validated);
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
                        'approval_status' => $existing->approval_status,
                        'completion_notes' => $existing->completion_notes,
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
                'approval_required' => (bool) $task->approval_required,
                'approval_status' => $task->approval_status,
                'completion_notes' => $task->completion_notes,
                'summary' => $task->approval_required
                    ? "Created approval task {$task->title}."
                    : "Created task {$task->title}.",
            ]
        );

        return $task;
    }

    public function updateForUser(int $userId, string $taskId, array $validated): Task
    {
        $task = Task::where('id', $taskId)->where('user_id', $userId)->firstOrFail();
        $validated = $this->attachOwnedStaffName($userId, $validated);
        $validated = $this->normalizeApprovalFields($userId, $validated, $task);
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
                'approval_status' => $task->approval_status,
                'completion_notes' => $task->completion_notes,
                'approval_comment' => $task->approval_comment,
                'summary' => match ($task->approval_status) {
                    'approved' => "Approved task {$task->title}.",
                    'rejected' => "Sent task {$task->title} back for changes.",
                    'pending' => "Task {$task->title} is waiting for approval.",
                    default => "Updated task {$task->title}.",
                },
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

        $farmId = $this->farmContextService->requireCurrentFarm($userId)->id;

        $staff = StaffMember::where('user_id', $userId)
            ->where(function ($query) use ($farmId, $userId) {
                $query->where('farm_id', $farmId)
                    ->orWhere(function ($legacy) use ($userId) {
                        $legacy->whereNull('farm_id')
                            ->where('user_id', $userId);
                    });
            })
            ->where('id', $validated['staff_member_id'])
            ->firstOrFail();

        if (! isset($validated['assigned_to']) || empty(trim((string) $validated['assigned_to']))) {
            $validated['assigned_to'] = $staff->name;
        }

        return $validated;
    }

    private function normalizeApprovalFields(int $userId, array $validated, ?Task $existingTask = null): array
    {
        $approvalRequired = array_key_exists('approval_required', $validated)
            ? (bool) $validated['approval_required']
            : ($existingTask?->approval_required ?? false);

        if (! $approvalRequired) {
            $validated['approval_required'] = false;
            $validated['approval_status'] = 'not_required';
            $validated['approved_by'] = null;
            $validated['approved_at'] = null;

            return $validated;
        }

        $validated['approval_required'] = true;

        $currentStatus = $existingTask?->approval_status ?? 'not_required';
        $nextStatus = $validated['approval_status'] ?? null;
        if (! is_string($nextStatus) || trim($nextStatus) === '') {
            $nextStatus = $currentStatus === 'not_required' ? 'pending' : $currentStatus;
        }

        $isApprovalDecision = in_array($nextStatus, ['approved', 'rejected'], true)
            && $nextStatus !== $currentStatus;

        if ($isApprovalDecision && ! $this->canApproveTasks($userId)) {
            throw new AuthorizationException('Only owners, managers, or accountants can approve sensitive tasks.');
        }

        $validated['approval_status'] = $nextStatus;

        if ($nextStatus === 'approved') {
            $validated['approved_by'] = (string) $userId;
            $validated['approved_at'] = now();
        } elseif ($nextStatus === 'rejected') {
            $validated['approved_by'] = null;
            $validated['approved_at'] = null;
        } elseif (! array_key_exists('approved_by', $validated)) {
            $validated['approved_by'] = $existingTask?->approved_by;
            $validated['approved_at'] = $existingTask?->approved_at;
        }

        if (! array_key_exists('approval_comment', $validated)) {
            $validated['approval_comment'] = $existingTask?->approval_comment;
        }

        return $validated;
    }

    private function canApproveTasks(int $userId): bool
    {
        return $this->farmContextService->canApproveTasks($userId);
    }
}
