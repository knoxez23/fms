<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('inventories', function (Blueprint $table) {
            $table->id();

            // Core item info
            $table->string('item_name');
            $table->string('category');

            // Stock info
            $table->decimal('quantity', 10, 2);
            $table->string('unit');
            $table->integer('min_stock')->default(0);

            // Supplier & pricing
            $table->string('supplier')->nullable();
            $table->decimal('unit_price', 12, 2)->nullable();
            $table->decimal('total_value', 14, 2)->nullable();

            // Notes & tracking
            $table->text('notes')->nullable();
            $table->timestamp('last_restock')->nullable();

            // Sync & conflict resolution
            $table->boolean('is_synced')->default(true);
            $table->unsignedBigInteger('server_id')->nullable();

            // Ownership
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();

            $table->timestamps();

            // Indexes
            $table->index('user_id');
            $table->index('is_synced');
            $table->index('server_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('inventories');
    }
};
