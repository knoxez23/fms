<?php

namespace App\Http\Requests\Sale;

use Illuminate\Foundation\Http\FormRequest;

class StoreSaleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'product_name' => 'required|string|max:255',
            'quantity' => 'required|numeric|min:0',
            'price' => 'required|numeric|min:0',
            'date' => 'required|date',
        ];
    }

    protected function prepareForValidation(): void
    {
        if (! $this->has('date') && $this->has('sale_date')) {
            $this->merge(['date' => $this->input('sale_date')]);
        }
    }
}
