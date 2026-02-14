<?php

namespace App\Http\Controllers;

use App\Http\Requests\Animal\StoreAnimalRequest;
use App\Http\Requests\Animal\UpdateAnimalRequest;
use App\Http\Resources\AnimalResource;
use App\Models\Animal;
use App\Services\Farm\AnimalService;

class AnimalController extends Controller
{
    public function __construct(private readonly AnimalService $animalService)
    {
    }

    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $animals = $this->animalService->listForUser((int) auth()->id());
        return $animals->map(fn (Animal $animal) => (new AnimalResource($animal))->resolve())->values();
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreAnimalRequest $request)
    {
        $animal = $this->animalService->createForUser((int) auth()->id(), $request->validated());
        return (new AnimalResource($animal))->response()->setStatusCode(201);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $animal = $this->animalService->showForUser((int) auth()->id(), $id);
        return new AnimalResource($animal);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateAnimalRequest $request, string $id)
    {
        $animal = $this->animalService->updateForUser((int) auth()->id(), $id, $request->validated());
        return new AnimalResource($animal);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $this->animalService->deleteForUser((int) auth()->id(), $id);
        return response()->noContent();
    }
}
