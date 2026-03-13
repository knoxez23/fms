<?php

namespace App\Http\Requests\Task;

use Illuminate\Foundation\Http\FormRequest;

class StoreTaskRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'client_uuid' => 'nullable|uuid',
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'due_date' => 'nullable|date',
            'priority' => 'nullable|string|max:50',
            'status' => 'nullable|string|max:50',
            'category' => 'nullable|string|max:100',
            'assigned_to' => 'nullable|string|max:255',
            'staff_member_id' => 'nullable|integer|exists:staff_members,id',
            'source_event_type' => 'nullable|string|max:100',
            'source_event_id' => 'nullable|string|max:255',
        ];
    }
}
