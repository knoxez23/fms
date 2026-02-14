<?php

namespace App\Services\Auth;

use App\Models\User;
use Laravel\Sanctum\PersonalAccessToken;

class TokenService
{
    private const ACCESS_TOKEN_EXPIRATION = 60; // minutes
    private const REFRESH_TOKEN_EXPIRATION = 10080; // 7 days in minutes

    public function createTokenPair(User $user): array
    {
        $user->tokens()->delete();

        $accessToken = $user->createToken(
            'access_token',
            ['*'],
            now()->addMinutes(self::ACCESS_TOKEN_EXPIRATION)
        );

        $refreshToken = $user->createToken(
            'refresh_token',
            ['refresh'],
            now()->addMinutes(self::REFRESH_TOKEN_EXPIRATION)
        );

        return [
            'access_token' => $accessToken->plainTextToken,
            'refresh_token' => $refreshToken->plainTextToken,
            'expires_at' => now()->addMinutes(self::ACCESS_TOKEN_EXPIRATION)->toISOString(),
        ];
    }

    public function refreshToken(string $refreshToken): array
    {
        $token = PersonalAccessToken::findToken($refreshToken);

        if (!$token || $token->name !== 'refresh_token') {
            throw new \Exception('Invalid refresh token');
        }

        if ($token->expires_at && $token->expires_at->isPast()) {
            throw new \Exception('Refresh token expired');
        }

        return $this->createTokenPair($token->tokenable);
    }
}
