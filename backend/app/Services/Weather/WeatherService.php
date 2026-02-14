<?php

namespace App\Services\Weather;

use Illuminate\Support\Facades\Http;

class WeatherService
{
    /**
     * @return array<string, mixed>
     */
    public function fetch(float $lat, float $lon): array
    {
        return $this->fetchFromProvider($lat, $lon) ?? $this->fallbackPayload();
    }

    /**
     * @return array<string, mixed>|null
     */
    private function fetchFromProvider(float $lat, float $lon): ?array
    {
        try {
            $response = Http::connectTimeout(1)
                ->timeout(2)
                ->get('https://api.open-meteo.com/v1/forecast', [
                    'latitude' => $lat,
                    'longitude' => $lon,
                    'current' => 'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,precipitation_probability',
                    'daily' => 'weather_code,temperature_2m_max,precipitation_probability_max',
                    'timezone' => 'auto',
                    'forecast_days' => 7,
                ]);

            if (! $response->successful()) {
                return null;
            }

            $data = $response->json();
            if (! is_array($data)) {
                return null;
            }

            $current = $data['current'] ?? [];
            $daily = $data['daily'] ?? [];
            $dates = $daily['time'] ?? [];
            $temps = $daily['temperature_2m_max'] ?? [];
            $codes = $daily['weather_code'] ?? [];
            $rains = $daily['precipitation_probability_max'] ?? [];

            $weekly = [];
            $count = min(count($dates), count($temps), count($codes));
            for ($i = 0; $i < $count; $i++) {
                $mapped = $this->mapWeatherCode((int) ($codes[$i] ?? 0));
                $weekly[] = [
                    'day' => (string) ($dates[$i] ?? ''),
                    'temp' => (int) round((float) ($temps[$i] ?? 0)),
                    'condition' => $mapped['condition'],
                    'icon' => $mapped['icon'],
                    'rain_chance' => (int) round((float) ($rains[$i] ?? 0)),
                ];
            }

            $mappedCurrent = $this->mapWeatherCode((int) ($current['weather_code'] ?? 0));

            return [
                'current' => [
                    'temp' => (int) round((float) ($current['temperature_2m'] ?? 0)),
                    'condition' => $mappedCurrent['condition'],
                    'icon' => $mappedCurrent['icon'],
                    'humidity' => (int) round((float) ($current['relative_humidity_2m'] ?? 0)),
                    'wind' => (int) round((float) ($current['wind_speed_10m'] ?? 0)),
                    'rain_chance' => (int) round((float) ($current['precipitation_probability'] ?? 0)),
                    'advice' => $mappedCurrent['advice'],
                ],
                'weekly' => $weekly,
            ];
        } catch (\Throwable) {
            return null;
        }
    }

    /**
     * @return array<string, mixed>
     */
    private function fallbackPayload(): array
    {
        $days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        $weekly = [];
        foreach ($days as $index => $day) {
            $weekly[] = [
                'day' => $day,
                'temp' => 22 + (($index * 2) % 7),
                'condition' => $index % 3 === 0 ? 'Partly Cloudy' : 'Sunny',
                'icon' => $index % 3 === 0 ? 'cloud' : 'wb_sunny',
                'rain_chance' => $index % 3 === 0 ? 35 : 12,
            ];
        }

        return [
            'current' => [
                'temp' => 24,
                'condition' => 'Partly Cloudy',
                'icon' => 'cloud',
                'humidity' => 68,
                'wind' => 11,
                'rain_chance' => 30,
                'advice' => 'Good time for field checks; keep rain cover ready.',
            ],
            'weekly' => $weekly,
        ];
    }

    /**
     * @return array{condition:string,icon:string,advice:string}
     */
    private function mapWeatherCode(int $code): array
    {
        return match (true) {
            $code === 0 => [
                'condition' => 'Clear',
                'icon' => 'wb_sunny',
                'advice' => 'Ideal conditions for spraying and harvest planning.',
            ],
            in_array($code, [1, 2, 3], true) => [
                'condition' => 'Partly Cloudy',
                'icon' => 'cloud',
                'advice' => 'Stable weather; proceed with regular field activities.',
            ],
            in_array($code, [45, 48], true) => [
                'condition' => 'Foggy',
                'icon' => 'foggy',
                'advice' => 'Delay early transport and monitor visibility on roads.',
            ],
            in_array($code, [51, 53, 55, 56, 57, 61, 63, 65], true) => [
                'condition' => 'Rainy',
                'icon' => 'umbrella',
                'advice' => 'Protect stored inputs and avoid heavy field machinery.',
            ],
            in_array($code, [66, 67, 71, 73, 75, 77, 85, 86], true) => [
                'condition' => 'Cold Precipitation',
                'icon' => 'ac_unit',
                'advice' => 'Check livestock shelter and water lines.',
            ],
            default => [
                'condition' => 'Stormy',
                'icon' => 'thunderstorm',
                'advice' => 'Postpone outdoor operations and secure farm equipment.',
            ],
        };
    }
}
