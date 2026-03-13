<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class FeedingLogResource extends JsonResource
{
    public static $wrap = null;

    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'animal_id' => $this->animal_id,
            'schedule_id' => $this->schedule_id,
            'inventory_id' => $this->inventory_id,
            'feed_type' => $this->feed_type,
            'quantity' => $this->quantity,
            'unit' => $this->unit,
            'fed_at' => optional($this->fed_at)?->toISOString(),
            'fed_by' => $this->fed_by,
            'notes' => $this->notes,
            'created_at' => optional($this->created_at)?->toISOString(),
            'updated_at' => optional($this->updated_at)?->toISOString(),
        ];
    }
}
