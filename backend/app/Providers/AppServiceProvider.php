<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Support\ServiceProvider;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Auth endpoints - very strict
        RateLimiter::for('auth', function (Request $request) {
            return Limit::perMinute(config('app.rate_limit_auth', 5))
                ->by($request->ip())
                ->response(function () {
                    return response()->json([
                        'message' => 'Too many login attempts. Please try again later.'
                    ], 429);
                });
        });

        // API endpoints - moderate
        RateLimiter::for('api', function (Request $request) {
            return Limit::perMinute(config('app.rate_limit_api', 60))
                ->by($request->user()?->id ?: $request->ip());
        });

        // File uploads - very strict
        RateLimiter::for('uploads', function (Request $request) {
            return Limit::perMinute(10)
                ->by($request->user()?->id ?: $request->ip());
        });
    }
}
