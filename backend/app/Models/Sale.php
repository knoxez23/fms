<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Sale extends Model
{
    use HasFactory;

    protected $fillable = [
        'product_name',
        'quantity',
        'unit',
        'price',
        'total_amount',
        'customer_name',
        'customer_id',
        'payment_status',
        'notes',
        'sale_date',
        'date',
        'user_id',
    ];

    protected $casts = [
        'quantity' => 'decimal:2',
        'price' => 'decimal:2',
        'total_amount' => 'decimal:2',
        'sale_date' => 'date',
        'date' => 'date',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function customerContact()
    {
        return $this->belongsTo(Customer::class, 'customer_id');
    }
}
