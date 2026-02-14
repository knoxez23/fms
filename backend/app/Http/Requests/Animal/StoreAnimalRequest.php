<?php

namespace App\Http\Requests\Animal;

use Illuminate\Foundation\Http\FormRequest;

class StoreAnimalRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => 'required|string|max:255',
            'type' => 'required|string|max:255',
            'breed' => 'nullable|string|max:255',
            'age' => 'nullable|integer|min:0',
            'weight' => 'nullable|numeric|min:0',
            'health_status' => 'nullable|string|max:255',
            'date_acquired' => 'nullable|date',
            'notes' => 'nullable|string',
        ];
    }
}

