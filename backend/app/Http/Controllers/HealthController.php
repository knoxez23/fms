<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\DB;

class HealthController extends Controller
{
    public function __invoke()
    {
        $dbStatus = 'up';
        try {
            DB::select('SELECT 1');
        } catch (\Throwable) {
            $dbStatus = 'down';
        }

        $status = $dbStatus === 'up' ? 'ok' : 'degraded';

        return response()->json([
            'status' => $status,
            'timestamp' => now()->toISOString(),
            'services' => [
                'database' => $dbStatus,
            ],
            'app' => [
                'env' => app()->environment(),
                'version' => config('app.version', 'unknown'),
            ],
        ], $status === 'ok' ? 200 : 503);
    }
}
