<?php

namespace App\Http\Controllers;

use App\Models\Sale;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class SaleController extends Controller
{
    public function index()
    {
        return Sale::where('user_id', auth()->id())
            ->orderBy('sale_date', 'desc')
            ->get();
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'product_name' => 'required|string|max:255',
            'quantity' => 'required|numeric|min:0',
            'unit' => 'required|string|max:50',
            'price' => 'required|numeric|min:0',
            'total_amount' => 'required|numeric|min:0',
            'customer_name' => 'required|string|max:255',
            'sale_date' => 'required|date',
            'payment_status' => 'nullable|string|in:Paid,Pending,Partial',
            'notes' => 'nullable|string',
        ]);

        $sale = Sale::create(array_merge($validated, ['user_id' => auth()->id()]));
        
        return response()->json($sale, 201);
    }

    public function show(string $id)
    {
        return Sale::where('id', $id)
            ->where('user_id', auth()->id())
            ->firstOrFail();
    }

    public function update(Request $request, string $id)
    {
        $sale = Sale::where('id', $id)
            ->where('user_id', auth()->id())
            ->firstOrFail();
            
        $validated = $request->validate([
            'product_name' => 'sometimes|required|string|max:255',
            'quantity' => 'sometimes|required|numeric|min:0',
            'unit' => 'sometimes|required|string|max:50',
            'price' => 'sometimes|required|numeric|min:0',
            'total_amount' => 'sometimes|required|numeric|min:0',
            'customer_name' => 'sometimes|required|string|max:255',
            'sale_date' => 'sometimes|required|date',
            'payment_status' => 'nullable|string|in:Paid,Pending,Partial',
            'notes' => 'nullable|string',
        ]);
        
        $sale->update($validated);
        return $sale;
    }

    public function destroy(string $id)
    {
        $sale = Sale::where('id', $id)
            ->where('user_id', auth()->id())
            ->firstOrFail();
            
        $sale->delete();
        return response()->noContent();
    }
}