<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FeedingLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'animal_id',
        'schedule_id',
        'inventory_id',
        'feed_type',
        'quantity',
        'unit',
        'fed_at',
        'fed_by',
        'notes',
    ];

    protected $casts = [
        'quantity' => 'decimal:2',
        'fed_at' => 'datetime',
    ];

    public function animal()
    {
        return $this->belongsTo(Animal::class);
    }

    public function feedingSchedule()
    {
        return $this->belongsTo(FeedingSchedule::class, 'schedule_id');
    }

    public function inventory()
    {
        return $this->belongsTo(Inventory::class, 'inventory_id');
    }
}
