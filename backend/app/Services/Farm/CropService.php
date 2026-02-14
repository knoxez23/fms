<?php

namespace App\Services\Farm;

use App\Models\Crop;
use Illuminate\Support\Collection;

class CropService
{
    /**
     * @return Collection<int, Crop>
     */
    public function listForUser(int $userId): Collection
    {
        return Crop::where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->get();
    }

    public function createForUser(int $userId, array $validated): Crop
    {
        return Crop::create(array_merge($validated, ['user_id' => $userId]));
    }

    public function updateForUser(int $userId, string $cropId, array $validated): Crop
    {
        $crop = Crop::where('id', $cropId)
            ->where('user_id', $userId)
            ->firstOrFail();

        $crop->update($validated);
        return $crop;
    }

    public function showForUser(int $userId, string $cropId): Crop
    {
        return Crop::where('id', $cropId)
            ->where('user_id', $userId)
            ->firstOrFail();
    }

    public function deleteForUser(int $userId, string $cropId): void
    {
        $crop = Crop::where('id', $cropId)
            ->where('user_id', $userId)
            ->firstOrFail();

        $crop->delete();
    }
}
