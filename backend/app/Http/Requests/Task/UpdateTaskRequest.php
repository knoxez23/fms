<?php

namespace App\Http\Requests\Task;

use Illuminate\Foundation\Http\FormRequest;

class UpdateTaskRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'client_uuid' => 'nullable|uuid',
            'title' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'due_date' => 'nullable|date',
            'priority' => 'nullable|string|max:50',
            'status' => 'nullable|string|max:50',
            'category' => 'nullable|string|max:100',
            'assigned_to' => 'nullable|string|max:255',
            'staff_member_id' => 'nullable|integer|exists:staff_members,id',
            'source_event_type' => 'nullable|string|max:100',
            'source_event_id' => 'nullable|string|max:255',
            'completion_notes' => 'nullable|string',
            'approval_required' => 'nullable|boolean',
            'approval_status' => 'nullable|in:not_required,pending,approved,rejected',
            'approved_by' => 'nullable|string|max:255',
            'approved_at' => 'nullable|date',
            'approval_comment' => 'nullable|string',
        ];
    }
}
