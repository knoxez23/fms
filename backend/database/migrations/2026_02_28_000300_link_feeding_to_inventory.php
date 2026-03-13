<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('feeding_schedules', function (Blueprint $table): void {
            if (! Schema::hasColumn('feeding_schedules', 'inventory_id')) {
                $table->foreignId('inventory_id')
                    ->nullable()
                    ->after('animal_id')
                    ->constrained('inventories')
                    ->nullOnDelete();
            }
        });

        Schema::table('feeding_logs', function (Blueprint $table): void {
            if (! Schema::hasColumn('feeding_logs', 'inventory_id')) {
                $table->foreignId('inventory_id')
                    ->nullable()
                    ->after('schedule_id')
                    ->constrained('inventories')
                    ->nullOnDelete();
            }
        });
    }

    public function down(): void
    {
        Schema::table('feeding_logs', function (Blueprint $table): void {
            if (Schema::hasColumn('feeding_logs', 'inventory_id')) {
                $table->dropConstrainedForeignId('inventory_id');
            }
        });

        Schema::table('feeding_schedules', function (Blueprint $table): void {
            if (Schema::hasColumn('feeding_schedules', 'inventory_id')) {
                $table->dropConstrainedForeignId('inventory_id');
            }
        });
    }
};
