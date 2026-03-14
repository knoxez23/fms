<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FarmMembership extends Model
{
    use HasFactory;

    protected $fillable = [
        'farm_id',
        'user_id',
        'role',
        'status',
        'is_default',
        'joined_at',
        'invited_by',
    ];

    protected $casts = [
        'is_default' => 'boolean',
        'joined_at' => 'datetime',
    ];

    public function farm(): BelongsTo
    {
        return $this->belongsTo(Farm::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function inviter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'invited_by');
    }
}
