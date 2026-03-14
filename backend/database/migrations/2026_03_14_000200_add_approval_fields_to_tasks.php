<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('tasks', function (Blueprint $table) {
            if (! Schema::hasColumn('tasks', 'approval_required')) {
                $table->boolean('approval_required')->default(false)->after('source_event_id');
            }
            if (! Schema::hasColumn('tasks', 'approval_status')) {
                $table->string('approval_status', 50)->default('not_required')->after('approval_required');
            }
            if (! Schema::hasColumn('tasks', 'approved_by')) {
                $table->string('approved_by')->nullable()->after('approval_status');
            }
            if (! Schema::hasColumn('tasks', 'approved_at')) {
                $table->timestamp('approved_at')->nullable()->after('approved_by');
            }
        });
    }

    public function down(): void
    {
        Schema::table('tasks', function (Blueprint $table) {
            foreach (['approved_at', 'approved_by', 'approval_status', 'approval_required'] as $column) {
                if (Schema::hasColumn('tasks', $column)) {
                    $table->dropColumn($column);
                }
            }
        });
    }
};
