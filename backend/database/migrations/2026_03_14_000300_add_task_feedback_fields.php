<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('tasks', function (Blueprint $table) {
            if (! Schema::hasColumn('tasks', 'completion_notes')) {
                $table->text('completion_notes')->nullable()->after('source_event_id');
            }
            if (! Schema::hasColumn('tasks', 'approval_comment')) {
                $table->text('approval_comment')->nullable()->after('approved_at');
            }
        });
    }

    public function down(): void
    {
        Schema::table('tasks', function (Blueprint $table) {
            foreach (['approval_comment', 'completion_notes'] as $column) {
                if (Schema::hasColumn('tasks', $column)) {
                    $table->dropColumn($column);
                }
            }
        });
    }
};
