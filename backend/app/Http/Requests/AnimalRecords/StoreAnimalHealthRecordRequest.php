<?php

namespace App\Http\Requests\AnimalRecords;

use Illuminate\Foundation\Http\FormRequest;

class StoreAnimalHealthRecordRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'animal_id' => 'required|integer|exists:animals,id',
            'type' => 'required|string|max:255',
            'name' => 'required|string|max:255',
            'notes' => 'nullable|string',
            'treated_at' => 'nullable|date',
        ];
    }
}

