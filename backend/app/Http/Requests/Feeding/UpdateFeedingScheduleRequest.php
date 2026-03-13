<?php

namespace App\Http\Requests\Feeding;

use Illuminate\Foundation\Http\FormRequest;

class UpdateFeedingScheduleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'animal_id' => 'sometimes|required|integer|exists:animals,id',
            'inventory_id' => 'nullable|integer|exists:inventories,id',
            'feed_type' => 'sometimes|required|string|max:255',
            'quantity' => 'sometimes|required|numeric|min:0',
            'unit' => 'sometimes|required|string|max:50',
            'time_of_day' => 'sometimes|required|string|max:100',
            'frequency' => 'sometimes|required|string|max:100',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date',
            'notes' => 'nullable|string',
            'completed' => 'nullable|boolean',
        ];
    }
}
