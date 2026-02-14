<?php

namespace App\Http\Controllers;

use App\Http\Requests\AnimalRecords\StoreAnimalHealthRecordRequest;
use App\Http\Requests\AnimalRecords\UpdateAnimalHealthRecordRequest;
use App\Http\Resources\AnimalHealthRecordResource;
use App\Models\AnimalHealthRecord;
use App\Services\Farm\AnimalHealthRecordService;

class AnimalHealthRecordController extends Controller
{
    public function __construct(private readonly AnimalHealthRecordService $animalHealthRecordService)
    {
    }

    public function index()
    {
        $items = $this->animalHealthRecordService->listForUser((int) auth()->id());
        return $items->map(fn (AnimalHealthRecord $record) => (new AnimalHealthRecordResource($record))->resolve())->values();
    }

    public function store(StoreAnimalHealthRecordRequest $request)
    {
        $created = $this->animalHealthRecordService->createForUser(auth()->user(), $request->validated());
        return (new AnimalHealthRecordResource($created))->response()->setStatusCode(201);
    }

    public function show($id)
    {
        $record = AnimalHealthRecord::where('id', $id)->where('user_id', auth()->id())->firstOrFail();
        return new AnimalHealthRecordResource($record);
    }

    public function update(UpdateAnimalHealthRecordRequest $request, $id)
    {
        $record = $this->animalHealthRecordService->updateForUser(auth()->user(), (string) $id, $request->validated());
        return new AnimalHealthRecordResource($record);
    }

    public function destroy($id)
    {
        $this->animalHealthRecordService->deleteForUser((int) auth()->id(), (string) $id);
        return response()->noContent();
    }
}
