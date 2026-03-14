<?php

namespace App\Http\Controllers;

use App\Services\Farm\FarmContextService;
use Illuminate\Http\JsonResponse;

class FarmContextController extends Controller
{
    public function __construct(private readonly FarmContextService $farmContextService)
    {
    }

    public function show(): JsonResponse
    {
        return response()->json(
            $this->farmContextService->currentContext((int) auth()->id())
        );
    }
}
