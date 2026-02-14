<?php

namespace App\Http\Requests\Sale;

use Illuminate\Foundation\Http\FormRequest;

class UpdateSaleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'product_name' => 'sometimes|required|string|max:255',
            'quantity' => 'sometimes|required|numeric|min:0',
            'price' => 'sometimes|required|numeric|min:0',
            'date' => 'sometimes|required|date',
        ];
    }

    protected function prepareForValidation(): void
    {
        if (! $this->has('date') && $this->has('sale_date')) {
            $this->merge(['date' => $this->input('sale_date')]);
        }
    }
}
