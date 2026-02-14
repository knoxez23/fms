<?php

namespace App\Http\Controllers;

use App\Http\Requests\Feeding\StoreFeedingLogRequest;
use App\Http\Requests\Feeding\UpdateFeedingLogRequest;
use App\Http\Resources\FeedingLogResource;
use App\Models\FeedingLog;
use App\Services\Farm\FeedingLogService;

class FeedingLogController extends Controller
{
    public function __construct(private readonly FeedingLogService $feedingLogService)
    {
    }

    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $logs = $this->feedingLogService->listForUser(auth()->user());
        return $logs->map(fn (FeedingLog $log) => (new FeedingLogResource($log))->resolve())->values();
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreFeedingLogRequest $request)
    {
        $created = $this->feedingLogService->createForUser(auth()->user(), $request->validated());
        return (new FeedingLogResource($created))->response()->setStatusCode(201);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $feedingLog = $this->feedingLogService->showForUser(auth()->user(), $id);
        return new FeedingLogResource($feedingLog);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateFeedingLogRequest $request, string $id)
    {
        $feedingLog = $this->feedingLogService->updateForUser(auth()->user(), $id, $request->validated());
        return new FeedingLogResource($feedingLog);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $this->feedingLogService->deleteForUser(auth()->user(), $id);
        return response()->noContent();
    }
}
