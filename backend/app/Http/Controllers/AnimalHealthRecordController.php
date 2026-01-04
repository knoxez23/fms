<?php

namespace App\Http\Controllers;

use App\Models\AnimalHealthRecord;
use Illuminate\Http\Request;

class AnimalHealthRecordController extends Controller
{
    public function index()
    {
        return AnimalHealthRecord::where('user_id', auth()->id())->with('animal')->get();
    }

    public function store(Request $request)
    {
        $request->validate([
            'animal_id' => 'required|exists:animals,id',
            'type' => 'required|string',
            'name' => 'required|string',
            'treated_at' => 'nullable|date',
        ]);

        $data = $request->all();
        $data['user_id'] = auth()->id();

        return AnimalHealthRecord::create($data);
    }

    public function show($id)
    {
        return AnimalHealthRecord::where('id', $id)->where('user_id', auth()->id())->firstOrFail();
    }

    public function update(Request $request, $id)
    {
        $record = AnimalHealthRecord::where('id', $id)->where('user_id', auth()->id())->firstOrFail();
        $record->update($request->all());
        return $record;
    }

    public function destroy($id)
    {
        $record = AnimalHealthRecord::where('id', $id)->where('user_id', auth()->id())->firstOrFail();
        $record->delete();
        return response()->noContent();
    }
}
