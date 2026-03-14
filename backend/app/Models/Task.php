<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Task extends Model
{
    use HasFactory;

    protected $fillable = [
        'client_uuid',
        'title',
        'description',
        'due_date',
        'priority',
        'status',
        'category',
        'assigned_to',
        'staff_member_id',
        'source_event_type',
        'source_event_id',
        'approval_required',
        'approval_status',
        'approved_by',
        'approved_at',
        'user_id',
    ];

    protected $casts = [
        'due_date' => 'date',
        'approval_required' => 'boolean',
        'approved_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function staffMember()
    {
        return $this->belongsTo(StaffMember::class, 'staff_member_id');
    }
}
