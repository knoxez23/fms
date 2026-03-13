<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FeedingSchedule extends Model
{
    use HasFactory;

    protected $fillable = [
        'animal_id',
        'inventory_id',
        'feed_type',
        'quantity',
        'unit',
        'time_of_day',
        'frequency',
        'start_date',
        'end_date',
        'notes',
        'completed',
    ];

    protected $casts = [
        'quantity' => 'decimal:2',
        'start_date' => 'date',
        'end_date' => 'date',
        'completed' => 'boolean',
    ];

    public function animal()
    {
        return $this->belongsTo(Animal::class);
    }

    public function feedingLogs()
    {
        return $this->hasMany(FeedingLog::class, 'schedule_id');
    }

    public function inventory()
    {
        return $this->belongsTo(Inventory::class, 'inventory_id');
    }
}
