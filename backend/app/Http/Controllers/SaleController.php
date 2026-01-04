<?php

namespace App\Http\Controllers;

use App\Models\Sale;
use Illuminate\Http\Request;

class SaleController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return Sale::where('user_id', auth()->id())->get();
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        return Sale::create(array_merge($request->all(), ['user_id' => auth()->id()]));
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        return Sale::where('id', $id)->where('user_id', auth()->id())->firstOrFail();
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $sale = Sale::where('id', $id)->where('user_id', auth()->id())->firstOrFail();
        $sale->update($request->all());
        return $sale;
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $sale = Sale::where('id', $id)->where('user_id', auth()->id())->firstOrFail();
        $sale->delete();
        return response()->noContent();
    }
}
