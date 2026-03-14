<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class InventoryResource extends JsonResource
{
    public static $wrap = null;

    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'item_name' => $this->item_name,
            'category' => $this->category,
            'lot_code' => $this->lot_code,
            'source_type' => $this->source_type,
            'source_ref' => $this->source_ref,
            'source_label' => $this->source_label,
            'quantity' => $this->quantity,
            'reserved_quantity' => $this->reserved_quantity,
            'available_quantity' => max(0, (float) $this->quantity - (float) $this->reserved_quantity),
            'unit' => $this->unit,
            'min_stock' => $this->min_stock,
            'supplier' => $this->supplier,
            'supplier_id' => $this->supplier_id,
            'unit_price' => $this->unit_price,
            'total_value' => $this->total_value,
            'notes' => $this->notes,
            'expiry_date' => optional($this->expiry_date)?->toISOString(),
            'freshness_hours' => $this->freshness_hours,
            'last_restock' => optional($this->last_restock)?->toISOString(),
            'is_synced' => (bool) $this->is_synced,
            'created_at' => optional($this->created_at)?->toISOString(),
            'updated_at' => optional($this->updated_at)?->toISOString(),
        ];
    }
}
