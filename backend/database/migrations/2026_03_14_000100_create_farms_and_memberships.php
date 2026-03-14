<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('farms', function (Blueprint $table) {
            $table->id();
            $table->foreignId('owner_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('name');
            $table->string('location')->nullable();
            $table->string('primary_enterprise')->nullable();
            $table->string('feed_measurement_style')->nullable();
            $table->json('profile')->nullable();
            $table->timestamps();
        });

        Schema::create('farm_memberships', function (Blueprint $table) {
            $table->id();
            $table->foreignId('farm_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('role')->default('worker');
            $table->string('status')->default('active');
            $table->boolean('is_default')->default(false);
            $table->timestamp('joined_at')->nullable();
            $table->foreignId('invited_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();

            $table->unique(['farm_id', 'user_id']);
            $table->index(['user_id', 'is_default']);
        });

        Schema::table('staff_members', function (Blueprint $table) {
            if (! Schema::hasColumn('staff_members', 'farm_id')) {
                $table->foreignId('farm_id')->nullable()->after('user_id')->constrained()->nullOnDelete();
            }
            if (! Schema::hasColumn('staff_members', 'employment_status')) {
                $table->string('employment_status')->nullable()->after('role');
            }
            if (! Schema::hasColumn('staff_members', 'assignment_area')) {
                $table->string('assignment_area')->nullable()->after('email');
            }
            if (! Schema::hasColumn('staff_members', 'can_login')) {
                $table->boolean('can_login')->default(false)->after('assignment_area');
            }
        });

        $users = DB::table('users')->get(['id', 'name', 'farm_name', 'location', 'created_at', 'updated_at']);
        foreach ($users as $user) {
            $farmId = DB::table('farms')->insertGetId([
                'owner_user_id' => $user->id,
                'name' => filled($user->farm_name) ? $user->farm_name : trim(($user->name ?? 'Farm Owner') . "'s Farm"),
                'location' => $user->location,
                'profile' => json_encode([
                    'seeded_from' => 'user_profile',
                ]),
                'created_at' => $user->created_at ?? now(),
                'updated_at' => $user->updated_at ?? now(),
            ]);

            DB::table('farm_memberships')->insert([
                'farm_id' => $farmId,
                'user_id' => $user->id,
                'role' => 'owner',
                'status' => 'active',
                'is_default' => true,
                'joined_at' => $user->created_at ?? now(),
                'invited_by' => $user->id,
                'created_at' => $user->created_at ?? now(),
                'updated_at' => $user->updated_at ?? now(),
            ]);

            DB::table('staff_members')
                ->where('user_id', $user->id)
                ->update([
                    'farm_id' => $farmId,
                    'employment_status' => DB::raw("COALESCE(employment_status, 'active')"),
                ]);
        }
    }

    public function down(): void
    {
        Schema::table('staff_members', function (Blueprint $table) {
            if (Schema::hasColumn('staff_members', 'farm_id')) {
                $table->dropForeign(['farm_id']);
                $table->dropColumn('farm_id');
            }
            if (Schema::hasColumn('staff_members', 'employment_status')) {
                $table->dropColumn('employment_status');
            }
            if (Schema::hasColumn('staff_members', 'assignment_area')) {
                $table->dropColumn('assignment_area');
            }
            if (Schema::hasColumn('staff_members', 'can_login')) {
                $table->dropColumn('can_login');
            }
        });

        Schema::dropIfExists('farm_memberships');
        Schema::dropIfExists('farms');
    }
};
