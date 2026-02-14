<?php

namespace App\Http\Controllers;

use App\Http\Requests\AnimalRecords\StoreAnimalWeightRequest;
use App\Http\Requests\AnimalRecords\UpdateAnimalWeightRequest;
use App\Http\Resources\AnimalWeightResource;
use App\Models\AnimalWeight;
use App\Services\Farm\AnimalWeightService;

class AnimalWeightController extends Controller
{
    public function __construct(private readonly AnimalWeightService $animalWeightService)
    {
    }

    public function index()
    {
        $perPage = (int) request()->query('per_page', 20);
        $animalId = request()->query('animal_id');
        $page = $this->animalWeightService->listForUser((int) auth()->id(), is_string($animalId) ? $animalId : null, $perPage);
        $page->setCollection(
            $page->getCollection()
                ->map(fn (AnimalWeight $record) => (new AnimalWeightResource($record))->resolve())
        );
        return $page;
    }

    public function store(StoreAnimalWeightRequest $request)
    {
        $created = $this->animalWeightService->createForUser(auth()->user(), $request->validated());
        return (new AnimalWeightResource($created))->response()->setStatusCode(201);
    }

    public function show($id)
    {
        $record = AnimalWeight::where('id', $id)->where('user_id', auth()->id())->firstOrFail();
        return new AnimalWeightResource($record);
    }

    public function update(UpdateAnimalWeightRequest $request, $id)
    {
        $record = $this->animalWeightService->updateForUser(auth()->user(), (string) $id, $request->validated());
        return new AnimalWeightResource($record);
    }

    public function destroy($id)
    {
        $this->animalWeightService->deleteForUser((int) auth()->id(), (string) $id);
        return response()->noContent();
    }
}
