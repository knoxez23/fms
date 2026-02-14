<?php

namespace App\Http\Controllers;

use App\Services\Audit\AuditEventService;
use Illuminate\Http\Request;

class AuditEventController extends Controller
{
    public function __construct(private readonly AuditEventService $auditService)
    {
    }

    public function index(Request $request)
    {
        $limit = (int) $request->query('limit', 100);

        return response()->json(
            $this->auditService->listForUser(
                userId: (int) auth()->id(),
                limit: $limit
            )
        );
    }
}
