<?php

namespace App\Http\Controllers;

use App\Models\Animal;
use Illuminate\Http\Request;

class AnimalController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return Animal::where('user_id', auth()->id())->get();
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'type' => 'required|string|max:255',
            'breed' => 'nullable|string|max:255',
            'age' => 'nullable|integer|min:0',
            'weight' => 'nullable|numeric|min:0',
            'health_status' => 'nullable|string|max:255',
            'date_acquired' => 'nullable|date',
            'notes' => 'nullable|string',
        ]);

        return Animal::create(array_merge($request->all(), ['user_id' => auth()->id()]));
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        return Animal::where('id', $id)->where('user_id', auth()->id())->firstOrFail();
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'type' => 'sometimes|required|string|max:255',
            'breed' => 'nullable|string|max:255',
            'age' => 'nullable|integer|min:0',
            'weight' => 'nullable|numeric|min:0',
            'health_status' => 'nullable|string|max:255',
            'date_acquired' => 'nullable|date',
            'notes' => 'nullable|string',
        ]);

        $animal = Animal::where('id', $id)->where('user_id', auth()->id())->firstOrFail();
        $animal->update($request->all());
        return $animal;
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $animal = Animal::where('id', $id)->where('user_id', auth()->id())->firstOrFail();
        $animal->delete();
        return response()->noContent();
    }
}
