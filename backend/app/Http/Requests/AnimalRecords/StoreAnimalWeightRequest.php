<?php

namespace App\Http\Requests\AnimalRecords;

use Illuminate\Foundation\Http\FormRequest;

class StoreAnimalWeightRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'animal_id' => 'required|integer|exists:animals,id',
            'weight' => 'required|numeric|min:0',
            'recorded_at' => 'nullable|date',
            'notes' => 'nullable|string',
        ];
    }
}

