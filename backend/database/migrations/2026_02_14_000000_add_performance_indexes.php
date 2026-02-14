<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('inventories', function (Blueprint $table) {
            $table->index(['user_id', 'updated_at'], 'inventories_user_updated_idx');
            $table->index(['user_id', 'category'], 'inventories_user_category_idx');
        });

        Schema::table('tasks', function (Blueprint $table) {
            $table->index(['user_id', 'status', 'due_date'], 'tasks_user_status_due_idx');
        });

        Schema::table('animals', function (Blueprint $table) {
            $table->index(['user_id', 'type'], 'animals_user_type_idx');
        });

        Schema::table('crops', function (Blueprint $table) {
            $table->index(['user_id', 'status', 'expected_harvest_date'], 'crops_user_status_harvest_idx');
        });

        Schema::table('sales', function (Blueprint $table) {
            $table->index(['user_id', 'sale_date'], 'sales_user_date_idx');
        });
    }

    public function down(): void
    {
        Schema::table('inventories', function (Blueprint $table) {
            $table->dropIndex('inventories_user_updated_idx');
            $table->dropIndex('inventories_user_category_idx');
        });

        Schema::table('tasks', function (Blueprint $table) {
            $table->dropIndex('tasks_user_status_due_idx');
        });

        Schema::table('animals', function (Blueprint $table) {
            $table->dropIndex('animals_user_type_idx');
        });

        Schema::table('crops', function (Blueprint $table) {
            $table->dropIndex('crops_user_status_harvest_idx');
        });

        Schema::table('sales', function (Blueprint $table) {
            $table->dropIndex('sales_user_date_idx');
        });
    }
};
