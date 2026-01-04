<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class TestUserSeeder extends Seeder
{
    public function run(): void
    {
        $user = User::firstOrCreate([
            'email' => 'test@local'
        ], [
            'name' => 'Test User',
            'password' => bcrypt('password'),
        ]);

        $token = $user->createToken('seed-token')->plainTextToken;

        // write token to storage/logs/seed_token.txt for developer convenience
        @file_put_contents(storage_path('logs/seed_token.txt'), "TOKEN={$token}\n");
    }
}
