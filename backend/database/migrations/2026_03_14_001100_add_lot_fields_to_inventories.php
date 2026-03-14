<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('inventories', function (Blueprint $table) {
            $table->string('lot_code')->nullable()->after('category');
            $table->string('source_type')->nullable()->after('lot_code');
            $table->string('source_ref')->nullable()->after('source_type');
            $table->string('source_label')->nullable()->after('source_ref');
            $table->decimal('reserved_quantity', 12, 2)->default(0)->after('quantity');
            $table->timestamp('expiry_date')->nullable()->after('notes');
            $table->unsignedInteger('freshness_hours')->nullable()->after('expiry_date');
        });
    }

    public function down(): void
    {
        Schema::table('inventories', function (Blueprint $table) {
            $table->dropColumn([
                'lot_code',
                'source_type',
                'source_ref',
                'source_label',
                'reserved_quantity',
                'expiry_date',
                'freshness_hours',
            ]);
        });
    }
};
