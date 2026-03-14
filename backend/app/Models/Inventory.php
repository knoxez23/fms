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
        'lot_code',
        'source_type',
        'source_ref',
        'source_label',
        'quantity',
        'reserved_quantity',
        'unit',
        'min_stock',
        'supplier',
        'supplier_id',
        'unit_price',
        'total_value',
        'notes',
        'expiry_date',
        'freshness_hours',
        'last_restock',
        'server_id',
        'is_synced',
        'user_id',
    ];

    protected $casts = [
        'quantity' => 'float',
        'reserved_quantity' => 'float',
        'unit_price' => 'float',
        'total_value' => 'float',
        'expiry_date' => 'datetime',
        'freshness_hours' => 'integer',
        'last_restock' => 'datetime',
        'is_synced' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function supplierContact()
    {
        return $this->belongsTo(Supplier::class, 'supplier_id');
    }
}
