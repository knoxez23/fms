<?php

namespace App\Http\Controllers;

use App\Http\Requests\Supplier\StoreSupplierRequest;
use App\Http\Requests\Supplier\UpdateSupplierRequest;
use App\Http\Resources\SupplierResource;
use App\Models\Supplier;
use App\Services\Farm\SupplierService;

class SupplierController extends Controller
{
    public function __construct(private readonly SupplierService $supplierService)
    {
    }

    public function index()
    {
        $items = $this->supplierService->listForUser((int) auth()->id());

        return $items->map(fn (Supplier $item) => (new SupplierResource($item))->resolve())->values();
    }

    public function store(StoreSupplierRequest $request)
    {
        $created = $this->supplierService->createForUser((int) auth()->id(), $request->validated());

        return (new SupplierResource($created))->response()->setStatusCode(201);
    }

    public function show(string $id)
    {
        $item = $this->supplierService->showForUser((int) auth()->id(), $id);

        return new SupplierResource($item);
    }

    public function update(UpdateSupplierRequest $request, string $id)
    {
        $item = $this->supplierService->updateForUser((int) auth()->id(), $id, $request->validated());

        return new SupplierResource($item);
    }

    public function destroy(string $id)
    {
        $this->supplierService->deleteForUser((int) auth()->id(), $id);

        return response()->noContent();
    }
}
