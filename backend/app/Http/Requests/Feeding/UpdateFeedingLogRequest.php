<?php

namespace App\Http\Requests\Feeding;

use Illuminate\Foundation\Http\FormRequest;

class UpdateFeedingLogRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'animal_id' => 'sometimes|required|integer|exists:animals,id',
            'schedule_id' => 'nullable|integer|exists:feeding_schedules,id',
            'feed_type' => 'sometimes|required|string|max:255',
            'quantity' => 'sometimes|required|numeric|min:0',
            'unit' => 'sometimes|required|string|max:50',
            'fed_at' => 'nullable|date',
            'fed_by' => 'nullable|string|max:255',
            'notes' => 'nullable|string',
        ];
    }
}

