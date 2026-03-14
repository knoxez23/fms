<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StaffMember extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'farm_id',
        'name',
        'role',
        'employment_status',
        'phone',
        'email',
        'assignment_area',
        'can_login',
        'notes',
    ];

    protected $casts = [
        'can_login' => 'boolean',
    ];

    public function farm(): BelongsTo
    {
        return $this->belongsTo(Farm::class);
    }
}
