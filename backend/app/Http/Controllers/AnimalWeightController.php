<?php

namespace App\Http\Controllers;

use App\Models\AnimalWeight;
use Illuminate\Http\Request;

class AnimalWeightController extends Controller
{
    public function index()
    {
        $query = AnimalWeight::where('user_id', auth()->id())->with('animal');

        if (request()->has('animal_id')) {
            $query->where('animal_id', request()->query('animal_id'));
        }

        // pagination: ?page=1&per_page=20
        $perPage = (int) request()->query('per_page', 20);
        return $query->orderBy('recorded_at', 'desc')->paginate($perPage);
    }

    public function store(Request $request)
    {
        $request->validate([
            'animal_id' => 'required|exists:animals,id',
            'weight' => 'required|numeric',
            'recorded_at' => 'nullable|date',
        ]);

        $data = $request->all();
        $data['user_id'] = auth()->id();

        return AnimalWeight::create($data);
    }

    public function show($id)
    {
        return AnimalWeight::where('id', $id)->where('user_id', auth()->id())->firstOrFail();
    }

    public function update(Request $request, $id)
    {
        $record = AnimalWeight::where('id', $id)->where('user_id', auth()->id())->firstOrFail();
        $record->update($request->all());
        return $record;
    }

    public function destroy($id)
    {
        $record = AnimalWeight::where('id', $id)->where('user_id', auth()->id())->firstOrFail();
        $record->delete();
        return response()->noContent();
    }
}
