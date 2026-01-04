<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AnimalHealthRecord extends Model
{
    use HasFactory;

    protected $fillable = ['animal_id', 'type', 'name', 'notes', 'treated_at', 'user_id'];

    protected $casts = [
        'treated_at' => 'date',
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
