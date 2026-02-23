<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('inventories', function (Blueprint $table) {
            if (! Schema::hasColumn('inventories', 'supplier_id')) {
                $table->foreignId('supplier_id')
                    ->nullable()
                    ->after('supplier')
                    ->constrained('suppliers')
                    ->nullOnDelete();
                $table->index(['user_id', 'supplier_id']);
            }
        });

        Schema::table('sales', function (Blueprint $table) {
            if (! Schema::hasColumn('sales', 'customer_id')) {
                $table->foreignId('customer_id')
                    ->nullable()
                    ->after('customer_name')
                    ->constrained('customers')
                    ->nullOnDelete();
                $table->index(['user_id', 'customer_id']);
            }
        });

        Schema::table('tasks', function (Blueprint $table) {
            if (! Schema::hasColumn('tasks', 'staff_member_id')) {
                $table->foreignId('staff_member_id')
                    ->nullable()
                    ->after('assigned_to')
                    ->constrained('staff_members')
                    ->nullOnDelete();
                $table->index(['user_id', 'staff_member_id']);
            }
        });
    }

    public function down(): void
    {
        Schema::table('tasks', function (Blueprint $table) {
            if (Schema::hasColumn('tasks', 'staff_member_id')) {
                $table->dropForeign(['staff_member_id']);
                $table->dropColumn('staff_member_id');
            }
        });

        Schema::table('sales', function (Blueprint $table) {
            if (Schema::hasColumn('sales', 'customer_id')) {
                $table->dropForeign(['customer_id']);
                $table->dropColumn('customer_id');
            }
        });

        Schema::table('inventories', function (Blueprint $table) {
            if (Schema::hasColumn('inventories', 'supplier_id')) {
                $table->dropForeign(['supplier_id']);
                $table->dropColumn('supplier_id');
            }
        });
    }
};
