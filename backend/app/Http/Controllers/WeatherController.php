<?php

namespace App\Http\Controllers;

use App\Http\Requests\Weather\IndexWeatherRequest;
use App\Http\Resources\WeatherResource;
use App\Services\Weather\WeatherService;

class WeatherController extends Controller
{
    public function __construct(
        private readonly WeatherService $weatherService
    ) {
    }

    public function index(IndexWeatherRequest $request): WeatherResource
    {
        $validated = $request->validated();

        $lat = (float) ($validated['lat'] ?? 1.2921);
        $lon = (float) ($validated['lon'] ?? 36.8219);
        $payload = $this->weatherService->fetch($lat, $lon);

        return new WeatherResource($payload);
    }
}
