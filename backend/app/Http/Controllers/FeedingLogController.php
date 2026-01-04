<?php

namespace App\Http\Controllers;

use App\Models\FeedingLog;
use Illuminate\Http\Request;

class FeedingLogController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $animalIds = auth()->user()->animals->pluck('id');
        return FeedingLog::whereIn('animal_id', $animalIds)->get();
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $animal = auth()->user()->animals()->findOrFail($request->animal_id);
        return FeedingLog::create($request->all());
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $feedingLog = FeedingLog::findOrFail($id);
        if (!auth()->user()->animals->contains('id', $feedingLog->animal_id)) {
            abort(403);
        }
        return $feedingLog;
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $feedingLog = FeedingLog::findOrFail($id);
        if (!auth()->user()->animals->contains('id', $feedingLog->animal_id)) {
            abort(403);
        }
        $feedingLog->update($request->all());
        return $feedingLog;
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $feedingLog = FeedingLog::findOrFail($id);
        if (!auth()->user()->animals->contains('id', $feedingLog->animal_id)) {
            abort(403);
        }
        $feedingLog->delete();
        return response()->noContent();
    }
}
