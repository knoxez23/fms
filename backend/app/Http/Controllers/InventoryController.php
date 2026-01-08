<?php

namespace App\Http\Controllers;

use App\Models\Inventory;
use Illuminate\Http\Request;

class InventoryController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return Inventory::where('user_id', auth()->id())->get();
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'item_name' => 'required|string',
            'category' => 'required|string',
            'quantity' => 'required|numeric',
            'unit' => 'required|string',
            'min_stock' => 'nullable|integer',
            'supplier' => 'nullable|string',
            'unit_price' => 'nullable|numeric',
            'total_value' => 'nullable|numeric',
            'notes' => 'nullable|string',
            'last_updated' => 'nullable|date',
        ]);

        return Inventory::create(
            array_merge($validated, [
                'user_id' => auth()->id(),
                'is_synced' => true,
            ])
        );
    }



    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        return Inventory::where('id', $id)->where('user_id', auth()->id())->firstOrFail();
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $inventory = Inventory::where('id', $id)->where('user_id', auth()->id())->firstOrFail();
        $inventory->update($request->all());
        return $inventory;
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $inventory = Inventory::where('id', $id)->where('user_id', auth()->id())->firstOrFail();
        $inventory->delete();
        return response()->noContent();
    }
}
