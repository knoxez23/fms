<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class SanitizeInput
{
    public function handle(Request $request, Closure $next): Response
    {
        $input = $request->all();

        array_walk_recursive($input, function (&$value) {
            if (is_string($value)) {
                $value = str_replace(chr(0), '', $value);
                $value = trim($value);
                $value = preg_replace('/[\x00-\x1F\x7F]/u', '', $value);
            }
        });

        $request->merge($input);

        return $next($request);
    }
}
