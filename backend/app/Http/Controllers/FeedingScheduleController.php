<?php

namespace App\Http\Controllers;

use App\Models\FeedingSchedule;
use Illuminate\Http\Request;

class FeedingScheduleController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $animalIds = auth()->user()->animals->pluck('id');
        return FeedingSchedule::whereIn('animal_id', $animalIds)->get();
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $animal = auth()->user()->animals()->findOrFail($request->animal_id);
        return FeedingSchedule::create($request->all());
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $feedingSchedule = FeedingSchedule::findOrFail($id);
        if (!auth()->user()->animals->contains('id', $feedingSchedule->animal_id)) {
            abort(403);
        }
        return $feedingSchedule;
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $feedingSchedule = FeedingSchedule::findOrFail($id);
        if (!auth()->user()->animals->contains('id', $feedingSchedule->animal_id)) {
            abort(403);
        }
        $feedingSchedule->update($request->all());
        return $feedingSchedule;
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $feedingSchedule = FeedingSchedule::findOrFail($id);
        if (!auth()->user()->animals->contains('id', $feedingSchedule->animal_id)) {
            abort(403);
        }
        $feedingSchedule->delete();
        return response()->noContent();
    }
}
