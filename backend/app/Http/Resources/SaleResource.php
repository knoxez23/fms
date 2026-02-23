<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SaleResource extends JsonResource
{
    public static $wrap = null;

    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'product_name' => $this->product_name,
            'quantity' => $this->quantity,
            'unit' => $this->unit,
            'price' => $this->price,
            'total_amount' => $this->total_amount,
            'customer_name' => $this->customer_name,
            'customer_id' => $this->customer_id,
            'payment_status' => $this->payment_status,
            'notes' => $this->notes,
            'date' => optional($this->date)?->toDateString(),
            'sale_date' => optional($this->sale_date ?? $this->date)?->toDateString(),
            'created_at' => optional($this->created_at)?->toISOString(),
            'updated_at' => optional($this->updated_at)?->toISOString(),
        ];
    }
}
