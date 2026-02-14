<?php

namespace App\Http\Controllers;

use App\Http\Requests\Inventory\StoreInventoryRequest;
use App\Http\Requests\Inventory\UpdateInventoryRequest;
use App\Http\Resources\InventoryResource;
use App\Models\Inventory;
use App\Services\Inventory\InventoryService;

class InventoryController extends Controller
{
    public function __construct(private readonly InventoryService $inventoryService)
    {
    }

    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $items = $this->inventoryService->listForUser((int) auth()->id());

        return $items->map(fn (Inventory $item) => (new InventoryResource($item))->resolve())->values();
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreInventoryRequest $request)
    {
        $result = $this->inventoryService->createOrUpsertByClientUuid(
            (int) auth()->id(),
            $request->validated()
        );

        return (new InventoryResource($result['inventory']))
            ->response()
            ->setStatusCode($result['status']);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $inventory = $this->inventoryService->showForUser((int) auth()->id(), $id);

        return new InventoryResource($inventory);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateInventoryRequest $request, string $id)
    {
        $inventory = $this->inventoryService->updateForUser(
            (int) auth()->id(),
            $id,
            $request->validated()
        );

        return new InventoryResource($inventory);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $this->inventoryService->deleteForUser((int) auth()->id(), $id);

        return response()->noContent();
    }

    /**
     * Idempotent delete by client UUID for offline sync fallbacks.
     */
    public function destroyByClientUuid(string $clientUuid)
    {
        validator(
            ['client_uuid' => $clientUuid],
            ['client_uuid' => 'required|uuid']
        )->validate();

        $this->inventoryService->deleteByClientUuid((int) auth()->id(), $clientUuid);

        return response()->noContent();
    }
}
