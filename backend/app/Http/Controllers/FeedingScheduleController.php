<?php

namespace App\Http\Controllers;

use App\Http\Requests\Feeding\StoreFeedingScheduleRequest;
use App\Http\Requests\Feeding\UpdateFeedingScheduleRequest;
use App\Http\Resources\FeedingScheduleResource;
use App\Models\FeedingSchedule;
use App\Services\Farm\FeedingScheduleService;

class FeedingScheduleController extends Controller
{
    public function __construct(private readonly FeedingScheduleService $feedingScheduleService)
    {
    }

    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $items = $this->feedingScheduleService->listForUser(auth()->user());
        return $items->map(fn (FeedingSchedule $item) => (new FeedingScheduleResource($item))->resolve())->values();
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreFeedingScheduleRequest $request)
    {
        $created = $this->feedingScheduleService->createForUser(auth()->user(), $request->validated());
        return (new FeedingScheduleResource($created))->response()->setStatusCode(201);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $feedingSchedule = $this->feedingScheduleService->showForUser(auth()->user(), $id);
        return new FeedingScheduleResource($feedingSchedule);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateFeedingScheduleRequest $request, string $id)
    {
        $feedingSchedule = $this->feedingScheduleService->updateForUser(auth()->user(), $id, $request->validated());
        return new FeedingScheduleResource($feedingSchedule);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $this->feedingScheduleService->deleteForUser(auth()->user(), $id);
        return response()->noContent();
    }
}
