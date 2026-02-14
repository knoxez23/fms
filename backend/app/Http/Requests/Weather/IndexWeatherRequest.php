<?php

namespace App\Http\Requests\Weather;

use Illuminate\Foundation\Http\FormRequest;

class IndexWeatherRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'lat' => ['nullable', 'numeric', 'between:-90,90'],
            'lon' => ['nullable', 'numeric', 'between:-180,180'],
        ];
    }
}
