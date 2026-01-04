<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('animals', function (Blueprint $table) {
            if (Schema::hasColumn('animals', 'weight')) {
                $table->dropColumn('weight');
            }
            if (Schema::hasColumn('animals', 'health_status')) {
                $table->dropColumn('health_status');
            }
        });
    }

    public function down(): void
    {
        Schema::table('animals', function (Blueprint $table) {
            $table->decimal('weight', 8, 2)->nullable();
            $table->string('health_status')->nullable();
        });
    }
};
