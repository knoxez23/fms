<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Animal extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'type',
        'breed',
        'age',
        'date_acquired',
        'notes',
        'user_id',
    ];

    protected $casts = [
        'weight' => 'decimal:2',
        'date_acquired' => 'date',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function feedingLogs()
    {
        return $this->hasMany(FeedingLog::class);
    }

    public function feedingSchedules()
    {
        return $this->hasMany(FeedingSchedule::class);
    }

    public function weights()
    {
        return $this->hasMany(AnimalWeight::class);
    }

    public function healthRecords()
    {
        return $this->hasMany(AnimalHealthRecord::class);
    }

    public function productionLogs()
    {
        return $this->hasMany(AnimalProductionLog::class);
    }
}
