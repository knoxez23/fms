<?php

namespace App\Http\Requests\Inventory;

use Illuminate\Foundation\Http\FormRequest;

class StoreInventoryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'client_uuid' => 'nullable|uuid',
            'item_name' => 'required|string|max:255',
            'category' => 'required|string|max:100',
            'quantity' => 'required|numeric|min:0',
            'unit' => 'required|string|max:50',
            'min_stock' => 'nullable|integer|min:0',
            'supplier' => 'nullable|string|max:255',
            'supplier_id' => 'nullable|integer|exists:suppliers,id',
            'unit_price' => 'nullable|numeric|min:0',
            'notes' => 'nullable|string',
            'last_restock' => 'nullable|date',
        ];
    }
}
