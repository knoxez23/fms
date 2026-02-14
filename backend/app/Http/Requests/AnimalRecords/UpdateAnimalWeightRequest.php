<?php

namespace App\Http\Requests\AnimalRecords;

use Illuminate\Foundation\Http\FormRequest;

class UpdateAnimalWeightRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'animal_id' => 'sometimes|required|integer|exists:animals,id',
            'weight' => 'sometimes|required|numeric|min:0',
            'recorded_at' => 'nullable|date',
            'notes' => 'nullable|string',
        ];
    }
}

