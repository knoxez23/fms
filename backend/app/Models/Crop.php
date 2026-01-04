<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Crop extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'variety',
        'planted_date',
        'expected_harvest_date',
        'area',
        'status',
        'notes',
        'user_id',
    ];

    protected $casts = [
        'planted_date' => 'date',
        'expected_harvest_date' => 'date',
        'area' => 'decimal:2',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
