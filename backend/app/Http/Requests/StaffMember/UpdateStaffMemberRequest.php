<?php

namespace App\Http\Requests\StaffMember;

use Illuminate\Foundation\Http\FormRequest;

class UpdateStaffMemberRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => 'sometimes|required|string|max:255',
            'role' => 'nullable|string|max:255',
            'employment_status' => 'nullable|in:active,inactive,seasonal,on_leave',
            'phone' => 'nullable|string|max:30',
            'email' => 'nullable|email|max:255',
            'assignment_area' => 'nullable|string|max:255',
            'can_login' => 'nullable|boolean',
            'notes' => 'nullable|string|max:1000',
        ];
    }
}
