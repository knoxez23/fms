<?php

namespace App\Http\Requests\Crop;

use Illuminate\Foundation\Http\FormRequest;

class StoreCropRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => 'required|string|max:255',
            'variety' => 'nullable|string|max:255',
            'planted_date' => 'required|date',
            'expected_harvest_date' => 'nullable|date',
            'area' => 'required|numeric',
            'status' => 'required|string|max:255',
            'notes' => 'nullable|string',
        ];
    }
}

