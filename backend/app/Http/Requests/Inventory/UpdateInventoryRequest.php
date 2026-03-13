<?php

namespace App\Http\Requests\Inventory;

use Illuminate\Foundation\Http\FormRequest;

class UpdateInventoryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'client_uuid' => 'nullable|uuid',
            'item_name' => 'sometimes|required|string|max:255',
            'category' => 'sometimes|required|string|max:100',
            'quantity' => 'sometimes|required|numeric|min:0',
            'unit' => 'sometimes|required|string|max:50',
            'min_stock' => 'nullable|integer|min:0',
            'supplier' => 'nullable|string|max:255',
            'supplier_id' => 'nullable|integer|exists:suppliers,id',
            'unit_price' => 'nullable|numeric|min:0',
            'notes' => 'nullable|string',
            'last_restock' => 'nullable|date',
        ];
    }
}
