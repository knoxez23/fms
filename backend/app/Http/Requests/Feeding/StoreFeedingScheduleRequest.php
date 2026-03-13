<?php

namespace App\Http\Requests\Feeding;

use Illuminate\Foundation\Http\FormRequest;

class StoreFeedingScheduleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'animal_id' => 'required|integer|exists:animals,id',
            'inventory_id' => 'nullable|integer|exists:inventories,id',
            'feed_type' => 'required|string|max:255',
            'quantity' => 'required|numeric|min:0',
            'unit' => 'required|string|max:50',
            'time_of_day' => 'required|string|max:100',
            'frequency' => 'required|string|max:100',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date',
            'notes' => 'nullable|string',
            'completed' => 'nullable|boolean',
        ];
    }
}
