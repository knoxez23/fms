<?php

namespace App\Http\Requests\Feeding;

use Illuminate\Foundation\Http\FormRequest;

class StoreFeedingLogRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'animal_id' => 'required|integer|exists:animals,id',
            'schedule_id' => 'nullable|integer|exists:feeding_schedules,id',
            'feed_type' => 'required|string|max:255',
            'quantity' => 'required|numeric|min:0',
            'unit' => 'required|string|max:50',
            'fed_at' => 'nullable|date',
            'fed_by' => 'nullable|string|max:255',
            'notes' => 'nullable|string',
        ];
    }
}

