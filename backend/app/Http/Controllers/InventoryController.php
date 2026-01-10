<?php

namespace App\Http\Controllers;

use App\Models\Inventory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;

class InventoryController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return Inventory::where('user_id', auth()->id())
            ->orderBy('created_at', 'desc')
            ->get();
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        // Log incoming request for debugging
        Log::info('Inventory store request', [
            'user_id' => auth()->id(),
            'data' => $request->all()
        ]);

        try {
            $validated = $request->validate([
                'item_name' => 'required|string|max:255',
                'category' => 'required|string|max:100',
                'quantity' => 'required|numeric|min:0',
                'unit' => 'required|string|max:50',
                'min_stock' => 'nullable|integer|min:0',
                'supplier' => 'nullable|string|max:255',
                'unit_price' => 'nullable|numeric|min:0',
                'total_value' => 'nullable|numeric|min:0',
                'notes' => 'nullable|string',
                'last_restock' => 'nullable|date',
            ]);

            // Create inventory with user_id
            $inventory = Inventory::create(array_merge($validated, [
                'user_id' => auth()->id(),
                'is_synced' => true,
            ]));

            Log::info('Inventory created successfully', [
                'id' => $inventory->id,
                'item_name' => $inventory->item_name
            ]);

            return response()->json($inventory, 201);

        } catch (ValidationException $e) {
            Log::error('Inventory validation failed', [
                'errors' => $e->errors(),
                'data' => $request->all()
            ]);
            throw $e;
        } catch (\Exception $e) {
            Log::error('Inventory store failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return response()->json([
                'message' => 'Failed to create inventory',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        return Inventory::where('id', $id)
            ->where('user_id', auth()->id())
            ->firstOrFail();
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        Log::info('Inventory update request', [
            'id' => $id,
            'user_id' => auth()->id(),
            'data' => $request->all()
        ]);

        $inventory = Inventory::where('id', $id)
            ->where('user_id', auth()->id())
            ->firstOrFail();

        try {
            $validated = $request->validate([
                'item_name' => 'sometimes|required|string|max:255',
                'category' => 'sometimes|required|string|max:100',
                'quantity' => 'sometimes|required|numeric|min:0',
                'unit' => 'sometimes|required|string|max:50',
                'min_stock' => 'nullable|integer|min:0',
                'supplier' => 'nullable|string|max:255',
                'unit_price' => 'nullable|numeric|min:0',
                'total_value' => 'nullable|numeric|min:0',
                'notes' => 'nullable|string',
                'last_restock' => 'nullable|date',
            ]);

            $inventory->update($validated);

            Log::info('Inventory updated successfully', ['id' => $inventory->id]);

            return response()->json($inventory);

        } catch (ValidationException $e) {
            Log::error('Inventory update validation failed', [
                'errors' => $e->errors(),
                'data' => $request->all()
            ]);
            throw $e;
        } catch (\Exception $e) {
            Log::error('Inventory update failed', [
                'error' => $e->getMessage()
            ]);
            return response()->json([
                'message' => 'Failed to update inventory',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $inventory = Inventory::where('id', $id)
            ->where('user_id', auth()->id())
            ->firstOrFail();

        $inventory->delete();

        Log::info('Inventory deleted successfully', ['id' => $id]);

        return response()->noContent();
    }
}