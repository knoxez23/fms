<?php

namespace App\Http\Controllers;

use App\Http\Requests\Crop\StoreCropRequest;
use App\Http\Requests\Crop\UpdateCropRequest;
use App\Http\Resources\CropResource;
use App\Models\Crop;
use App\Services\Farm\CropService;

class CropController extends Controller
{
    public function __construct(private readonly CropService $cropService)
    {
    }

    public function index()
    {
        $crops = $this->cropService->listForUser((int) auth()->id());

        return $crops->map(fn (Crop $crop) => (new CropResource($crop))->resolve())->values();
    }

    public function store(StoreCropRequest $request)
    {
        $crop = $this->cropService->createForUser((int) auth()->id(), $request->validated());

        return (new CropResource($crop))->response()->setStatusCode(201);
    }

    public function show(string $id)
    {
        $crop = $this->cropService->showForUser((int) auth()->id(), $id);

        return new CropResource($crop);
    }

    public function update(UpdateCropRequest $request, string $id)
    {
        $crop = $this->cropService->updateForUser((int) auth()->id(), $id, $request->validated());

        return new CropResource($crop);
    }

    public function destroy(string $id)
    {
        $this->cropService->deleteForUser((int) auth()->id(), $id);

        return response()->noContent();
    }
}
