<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AnimalWeight extends Model
{
    use HasFactory;

    protected $fillable = ['animal_id', 'weight', 'recorded_at', 'notes', 'user_id'];

    protected $casts = [
        'weight' => 'decimal:2',
        'recorded_at' => 'date',
    ];

    public function animal()
    {
        return $this->belongsTo(Animal::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
