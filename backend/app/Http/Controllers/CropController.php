<?php

namespace App\Http\Controllers;

use App\Models\Crop;
use Illuminate\Http\Request;

class CropController extends Controller
{
    public function index()
    {
        return Crop::where('user_id', auth()->id())
            ->orderBy('created_at', 'desc')
            ->get();
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'variety' => 'nullable|string|max:255',
            'planted_date' => 'required|date',
            'expected_harvest_date' => 'nullable|date',
            'area' => 'required|numeric',
            'status' => 'required|string|max:255',
            'notes' => 'nullable|string',
        ]);

        return Crop::create(array_merge(
            $data,
            ['user_id' => auth()->id()]
        ));
    }

    public function show(string $id)
    {
        return Crop::where('id', $id)
            ->where('user_id', auth()->id())
            ->firstOrFail();
    }

    public function update(Request $request, string $id)
    {
        $crop = Crop::where('id', $id)
            ->where('user_id', auth()->id())
            ->firstOrFail();

        $data = $request->validate([
            'name' => 'required|string|max:255',
            'variety' => 'nullable|string|max:255',
            'planted_date' => 'required|date',
            'expected_harvest_date' => 'nullable|date',
            'area' => 'required|numeric',
            'status' => 'required|string|max:255',
            'notes' => 'nullable|string',
        ]);

        $crop->update($data);

        return $crop;
    }

    public function destroy(string $id)
    {
        $crop = Crop::where('id', $id)
            ->where('user_id', auth()->id())
            ->firstOrFail();

        $crop->delete();

        return response()->noContent();
    }
}
