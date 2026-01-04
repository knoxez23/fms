<?php

namespace App\Http\Controllers;

use App\Models\AnimalProductionLog;
use Illuminate\Http\Request;

class AnimalProductionLogController extends Controller
{
    public function index()
    {
        return AnimalProductionLog::where('user_id', auth()->id())->with('animal')->get();
    }

    public function store(Request $request)
    {
        $request->validate([
            'animal_id' => 'required|exists:animals,id',
            'type' => 'required|string',
            'quantity' => 'nullable|numeric',
            'produced_at' => 'nullable|date',
        ]);

        $data = $request->all();
        $data['user_id'] = auth()->id();

        return AnimalProductionLog::create($data);
    }

    public function show($id)
    {
        return AnimalProductionLog::where('id', $id)->where('user_id', auth()->id())->firstOrFail();
    }

    public function update(Request $request, $id)
    {
        $record = AnimalProductionLog::where('id', $id)->where('user_id', auth()->id())->firstOrFail();
        $record->update($request->all());
        return $record;
    }

    public function destroy($id)
    {
        $record = AnimalProductionLog::where('id', $id)->where('user_id', auth()->id())->firstOrFail();
        $record->delete();
        return response()->noContent();
    }
}
