<?php

namespace App\Rules;

use Closure;
use Illuminate\Contracts\Validation\ValidationRule;

class StrongPassword implements ValidationRule
{
    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        $minLength = config('auth.password_min_length', 12);

        if (strlen($value) < $minLength) {
            $fail("The {$attribute} must be at least {$minLength} characters.");
            return;
        }

        if (config('auth.password_require_uppercase', true) && !preg_match('/[A-Z]/', $value)) {
            $fail("The {$attribute} must contain at least one uppercase letter.");
            return;
        }

        if (config('auth.password_require_lowercase', true) && !preg_match('/[a-z]/', $value)) {
            $fail("The {$attribute} must contain at least one lowercase letter.");
            return;
        }

        if (config('auth.password_require_numbers', true) && !preg_match('/[0-9]/', $value)) {
            $fail("The {$attribute} must contain at least one number.");
            return;
        }

        if (config('auth.password_require_symbols', true) && !preg_match('/[^A-Za-z0-9]/', $value)) {
            $fail("The {$attribute} must contain at least one special character.");
            return;
        }

        $commonPasswords = ['password', '12345678', 'qwerty', 'admin123', 'letmein'];
        if (in_array(strtolower((string) $value), $commonPasswords, true)) {
            $fail("The {$attribute} is too common. Please choose a stronger password.");
        }
    }
}
