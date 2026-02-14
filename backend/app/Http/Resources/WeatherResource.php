<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WeatherResource extends JsonResource
{
    public static $wrap = null;

    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var array<string, mixed> $payload */
        $payload = is_array($this->resource) ? $this->resource : [];

        return [
            'current' => [
                'temp' => (int) ($payload['current']['temp'] ?? 0),
                'condition' => (string) ($payload['current']['condition'] ?? ''),
                'icon' => (string) ($payload['current']['icon'] ?? 'wb_sunny'),
                'humidity' => (int) ($payload['current']['humidity'] ?? 0),
                'wind' => (int) ($payload['current']['wind'] ?? 0),
                'rain_chance' => (int) ($payload['current']['rain_chance'] ?? 0),
                'advice' => (string) ($payload['current']['advice'] ?? ''),
            ],
            'weekly' => collect($payload['weekly'] ?? [])->map(
                fn ($day) => [
                    'day' => (string) ($day['day'] ?? ''),
                    'temp' => (int) ($day['temp'] ?? 0),
                    'condition' => (string) ($day['condition'] ?? ''),
                    'icon' => (string) ($day['icon'] ?? 'wb_sunny'),
                    'rain_chance' => (int) ($day['rain_chance'] ?? 0),
                ]
            )->values()->all(),
        ];
    }
}
