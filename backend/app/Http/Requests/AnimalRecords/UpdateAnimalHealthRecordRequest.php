<?php

namespace App\Http\Requests\AnimalRecords;

use Illuminate\Foundation\Http\FormRequest;

class UpdateAnimalHealthRecordRequest extends FormRequest
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
            'name' => 'sometimes|required|string|max:255',
            'notes' => 'nullable|string',
            'treated_at' => 'nullable|date',
        ];
    }
}

