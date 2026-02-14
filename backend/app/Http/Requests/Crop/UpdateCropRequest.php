<?php

namespace App\Http\Requests\Crop;

use Illuminate\Foundation\Http\FormRequest;

class UpdateCropRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => 'sometimes|required|string|max:255',
            'variety' => 'nullable|string|max:255',
            'planted_date' => 'sometimes|required|date',
            'expected_harvest_date' => 'nullable|date',
            'area' => 'sometimes|required|numeric',
            'status' => 'sometimes|required|string|max:255',
            'notes' => 'nullable|string',
        ];
    }
}

