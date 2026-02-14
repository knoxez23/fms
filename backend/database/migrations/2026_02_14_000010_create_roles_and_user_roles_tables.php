<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('roles', function (Blueprint $table) {
            $table->id();
            $table->string('name')->unique();
            $table->json('permissions')->nullable();
            $table->timestamps();
        });

        Schema::create('role_user', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('role_id')->constrained()->cascadeOnDelete();
            $table->foreignId('assigned_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();

            $table->unique(['user_id', 'role_id']);
        });

        DB::table('roles')->insert([
            [
                'name' => 'owner',
                'permissions' => json_encode(['*']),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'manager',
                'permissions' => json_encode([
                    'animals.read', 'animals.write',
                    'crops.read', 'crops.write',
                    'tasks.read', 'tasks.write',
                    'inventory.read', 'inventory.write',
                    'sales.read',
                ]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'worker',
                'permissions' => json_encode([
                    'animals.read',
                    'crops.read',
                    'tasks.read', 'tasks.write',
                    'inventory.read',
                ]),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('role_user');
        Schema::dropIfExists('roles');
    }
};
