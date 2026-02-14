<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TaskResource extends JsonResource
{
    public static $wrap = null;

    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'description' => $this->description,
            'due_date' => optional($this->due_date)?->toISOString(),
            'priority' => $this->priority,
            'status' => $this->status,
            'category' => $this->category,
            'assigned_to' => $this->assigned_to,
            'source_event_type' => $this->source_event_type,
            'source_event_id' => $this->source_event_id,
            'created_at' => optional($this->created_at)?->toISOString(),
            'updated_at' => optional($this->updated_at)?->toISOString(),
        ];
    }
}

