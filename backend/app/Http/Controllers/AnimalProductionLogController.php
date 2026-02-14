<?php

namespace App\Http\Controllers;

use App\Http\Requests\AnimalRecords\StoreAnimalProductionLogRequest;
use App\Http\Requests\AnimalRecords\UpdateAnimalProductionLogRequest;
use App\Http\Resources\AnimalProductionLogResource;
use App\Models\AnimalProductionLog;
use App\Services\Farm\AnimalProductionLogService;

class AnimalProductionLogController extends Controller
{
    public function __construct(private readonly AnimalProductionLogService $animalProductionLogService)
    {
    }

    public function index()
    {
        $items = $this->animalProductionLogService->listForUser((int) auth()->id());
        return $items->map(fn (AnimalProductionLog $record) => (new AnimalProductionLogResource($record))->resolve())->values();
    }

    public function store(StoreAnimalProductionLogRequest $request)
    {
        $created = $this->animalProductionLogService->createForUser(auth()->user(), $request->validated());
        return (new AnimalProductionLogResource($created))->response()->setStatusCode(201);
    }

    public function show($id)
    {
        $record = AnimalProductionLog::where('id', $id)->where('user_id', auth()->id())->firstOrFail();
        return new AnimalProductionLogResource($record);
    }

    public function update(UpdateAnimalProductionLogRequest $request, $id)
    {
        $record = $this->animalProductionLogService->updateForUser(auth()->user(), (string) $id, $request->validated());
        return new AnimalProductionLogResource($record);
    }

    public function destroy($id)
    {
        $this->animalProductionLogService->deleteForUser((int) auth()->id(), (string) $id);
        return response()->noContent();
    }
}
