<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AnimalProductionLog extends Model
{
    use HasFactory;

    protected $fillable = ['animal_id', 'type', 'quantity', 'unit', 'produced_at', 'notes', 'user_id'];

    protected $casts = [
        'quantity' => 'decimal:2',
        'produced_at' => 'date',
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
