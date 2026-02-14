<?php

namespace App\Http\Requests\AnimalRecords;

use Illuminate\Foundation\Http\FormRequest;

class UpdateAnimalProductionLogRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'animal_id' => 'sometimes|required|integer|exists:animals,id',
            'type' => 'sometimes|required|string|max:255',
            'quantity' => 'nullable|numeric|min:0',
            'unit' => 'nullable|string|max:50',
            'produced_at' => 'nullable|date',
            'notes' => 'nullable|string',
        ];
    }
}

