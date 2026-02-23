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
            'unit' => 'nullable|string|max:50',
            'price' => 'required|numeric|min:0',
            'total_amount' => 'nullable|numeric|min:0',
            'customer_name' => 'nullable|string|max:255',
            'customer_id' => 'nullable|integer|exists:customers,id',
            'payment_status' => 'nullable|string|max:50',
            'notes' => 'nullable|string',
            'sale_date' => 'nullable|date',
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
