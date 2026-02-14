<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Inventory extends Model
{
    use HasFactory;

    protected $fillable = [
        'client_uuid',
        'item_name',
        'category',
        'quantity',
        'unit',
        'min_stock',
        'supplier',
        'unit_price',
        'total_value',
        'notes',
        'last_restock',
        'server_id',
        'is_synced',
        'user_id',
    ];

    protected $casts = [
        'quantity' => 'float',
        'unit_price' => 'float',
        'total_value' => 'float',
        'last_restock' => 'datetime',
        'is_synced' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
