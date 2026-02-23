<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('sales', function (Blueprint $table) {
            if (! Schema::hasColumn('sales', 'unit')) {
                $table->string('unit')->nullable()->after('quantity');
            }
            if (! Schema::hasColumn('sales', 'total_amount')) {
                $table->decimal('total_amount', 12, 2)->nullable()->after('price');
            }
            if (! Schema::hasColumn('sales', 'customer_name')) {
                $table->string('customer_name')->nullable()->after('total_amount');
            }
            if (! Schema::hasColumn('sales', 'payment_status')) {
                $table->string('payment_status')->nullable()->after('customer_name');
            }
            if (! Schema::hasColumn('sales', 'notes')) {
                $table->text('notes')->nullable()->after('payment_status');
            }
            if (! Schema::hasColumn('sales', 'sale_date')) {
                $table->date('sale_date')->nullable()->after('notes');
            }
        });
    }

    public function down(): void
    {
        Schema::table('sales', function (Blueprint $table) {
            $drops = [];
            foreach (['unit', 'total_amount', 'customer_name', 'payment_status', 'notes', 'sale_date'] as $column) {
                if (Schema::hasColumn('sales', $column)) {
                    $drops[] = $column;
                }
            }

            if (! empty($drops)) {
                $table->dropColumn($drops);
            }
        });
    }
};
