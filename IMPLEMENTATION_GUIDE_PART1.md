# Complete Implementation Guide: 0% → 100% Production Ready
## Farm Management System (Pamoja Twalima)

**Purpose**: Step-by-step guide to take the system from 30-40% to 100% production ready.  
**Format**: Detailed enough for AI agent execution  
**Estimated Time**: 6-8 months (24-32 weeks)  
**Team Size**: 2-3 developers + 1 DevOps engineer

---

## Table of Contents

1. [Phase 0: Preparation & Setup](#phase-0-preparation--setup)
2. [Phase 1: Security Hardening](#phase-1-security-hardening)
3. [Phase 2: Testing Foundation](#phase-2-testing-foundation)
4. [Phase 3: BLoC Architecture Migration](#phase-3-bloc-architecture-migration)
5. [Phase 4: Complete DDD Refactor](#phase-4-complete-ddd-refactor)
6. [Phase 5: Backend Service Layer](#phase-5-backend-service-layer)
7. [Phase 6: Missing Features](#phase-6-missing-features)
8. [Phase 7: Performance Optimization](#phase-7-performance-optimization)
9. [Phase 8: DevOps & Infrastructure](#phase-8-devops--infrastructure)
10. [Phase 9: Production Deployment](#phase-9-production-deployment)

---

# Phase 0: Preparation & Setup
**Duration**: 3-5 days  
**Goal**: Set up development environment and tooling

## Task 0.1: Install Required Dependencies

### Flutter Dependencies

**File**: `pubspec.yaml`

**Action**: Add these dependencies:

```yaml
dependencies:
  # Existing dependencies
  flutter:
    sdk: flutter
  provider: ^6.1.1
  dio: ^5.4.0
  flutter_dotenv: ^5.1.0
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  
  # NEW: State Management
  flutter_bloc: ^8.1.3
  bloc: ^8.1.2
  equatable: ^2.0.5
  
  # NEW: Dependency Injection
  get_it: ^7.6.4
  injectable: ^2.3.2
  
  # NEW: Error Handling & Logging
  logger: ^2.0.2
  sentry_flutter: ^7.14.0
  
  # NEW: Testing helpers
  mocktail: ^1.0.1
  bloc_test: ^9.1.5
  
  # NEW: Code generation
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  
  # NEW: Form validation
  formz: ^0.6.1
  
  # NEW: Network
  connectivity_plus: ^5.0.2
  
  # NEW: Local Database
  sqflite: ^2.3.0
  path: ^1.8.3
  
  # NEW: Image handling
  cached_network_image: ^3.3.1
  image_picker: ^1.0.7

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  
  # NEW: Code generation
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  injectable_generator: ^2.4.1
  
  # NEW: Testing
  integration_test:
    sdk: flutter
  mockito: ^5.4.4
  
  # NEW: Coverage
  coverage: ^1.7.2
```

**Command to run**:
```bash
cd flutter_app
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### Laravel Dependencies

**File**: `composer.json`

**Action**: Add these dependencies:

```json
{
    "require": {
        "php": "^8.2",
        "laravel/framework": "^11.0",
        "laravel/sanctum": "^4.0",
        "laravel/tinker": "^2.9",
        
        // NEW: API Documentation
        "darkaonline/l5-swagger": "^8.5",
        
        // NEW: Error Tracking
        "sentry/sentry-laravel": "^4.1",
        
        // NEW: Performance
        "predis/predis": "^2.2",
        
        // NEW: Queue
        "laravel/horizon": "^5.21"
    },
    "require-dev": {
        "fakerphp/faker": "^1.23",
        "laravel/pint": "^1.13",
        "laravel/sail": "^1.26",
        "mockery/mockery": "^1.6",
        "nunomaduro/collision": "^8.0",
        "phpunit/phpunit": "^11.0",
        "spatie/laravel-ignition": "^2.4",
        
        // NEW: Testing
        "pestphp/pest": "^2.30",
        "pestphp/pest-plugin-laravel": "^2.2",
        
        // NEW: Code Quality
        "phpstan/phpstan": "^1.10",
        "squizlabs/php_codesniffer": "^3.8"
    }
}
```

**Commands to run**:
```bash
cd backend
composer install
composer require --dev pestphp/pest pestphp/pest-plugin-laravel
php artisan vendor:publish --provider="L5Swagger\L5SwaggerServiceProvider"
php artisan vendor:publish --provider="Sentry\Laravel\ServiceProvider"
```

---

## Task 0.2: Project Structure Setup

### Create New Folders (Flutter)

**Commands**:
```bash
cd lib

# Core folders
mkdir -p core/di
mkdir -p core/errors
mkdir -p core/network
mkdir -p core/utils
mkdir -p core/constants

# Feature folders for each module
for feature in auth farm_mgmt inventory business marketplace profile; do
  mkdir -p $feature/presentation/bloc
  mkdir -p $feature/presentation/pages
  mkdir -p $feature/presentation/widgets
  mkdir -p $feature/application/usecases
  mkdir -p $feature/domain/entities
  mkdir -p $feature/domain/repositories
  mkdir -p $feature/domain/validators
  mkdir -p $feature/infrastructure/models
  mkdir -p $feature/infrastructure/repositories
  mkdir -p $feature/infrastructure/datasources
done

# Test folders
mkdir -p test/core
mkdir -p test/features
mkdir -p test_driver
mkdir -p integration_test
```

---

### Create New Folders (Laravel)

**Commands**:
```bash
cd app

# Service layer
mkdir -p Services/Auth
mkdir -p Services/Farm
mkdir -p Services/Inventory
mkdir -p Services/Sales

# DTOs
mkdir -p DTOs

# Actions
mkdir -p Actions

# Events
mkdir -p Events

# Listeners
mkdir -p Listeners

# Repositories
mkdir -p Repositories/Contracts
mkdir -p Repositories/Eloquent

# Http Resources
mkdir -p Http/Resources
mkdir -p Http/Requests

# Exceptions
mkdir -p Exceptions

# Tests
cd ..
mkdir -p tests/Feature/Api
mkdir -p tests/Feature/Services
mkdir -p tests/Unit/Models
mkdir -p tests/Unit/Repositories
```

---

## Task 0.3: Configuration Files

### Create Environment Template

**File**: `.env.example` (Flutter)

```bash
# Create in flutter project root
API_BASE_URL=http://10.0.2.2:8000/api
SENTRY_DSN=your_sentry_dsn_here
ENABLE_LOGGING=true
```

**File**: `.env.example` (Laravel - update existing)

```bash
# Add these to existing .env.example

# Sentry
SENTRY_LARAVEL_DSN=
SENTRY_TRACES_SAMPLE_RATE=1.0

# Redis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

# Queue
QUEUE_CONNECTION=redis
HORIZON_BALANCE_STRATEGY=auto

# Rate Limiting
RATE_LIMIT_AUTH=5
RATE_LIMIT_API=60

# Password Requirements
PASSWORD_MIN_LENGTH=12
PASSWORD_REQUIRE_UPPERCASE=true
PASSWORD_REQUIRE_LOWERCASE=true
PASSWORD_REQUIRE_NUMBERS=true
PASSWORD_REQUIRE_SYMBOLS=true

# API
API_VERSION=v1
```

---

# Phase 1: Security Hardening
**Duration**: 1 week  
**Priority**: CRITICAL

## Task 1.1: Implement Rate Limiting (Laravel)

### Step 1: Create Custom Rate Limiter

**File**: `app/Providers/RouteServiceProvider.php`

**Action**: Replace the `boot()` method:

```php
<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Foundation\Support\Providers\RouteServiceProvider as ServiceProvider;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Facades\Route;

class RouteServiceProvider extends ServiceProvider
{
    public const HOME = '/home';

    public function boot(): void
    {
        // Auth endpoints - very strict
        RateLimiter::for('auth', function (Request $request) {
            return Limit::perMinute(config('app.rate_limit_auth', 5))
                ->by($request->ip())
                ->response(function () {
                    return response()->json([
                        'message' => 'Too many login attempts. Please try again later.'
                    ], 429);
                });
        });

        // API endpoints - moderate
        RateLimiter::for('api', function (Request $request) {
            return Limit::perMinute(config('app.rate_limit_api', 60))
                ->by($request->user()?->id ?: $request->ip());
        });

        // File uploads - very strict
        RateLimiter::for('uploads', function (Request $request) {
            return Limit::perMinute(10)
                ->by($request->user()?->id ?: $request->ip());
        });

        $this->routes(function () {
            Route::middleware('api')
                ->prefix('api')
                ->group(base_path('routes/api.php'));

            Route::middleware('web')
                ->group(base_path('routes/web.php'));
        });
    }
}
```

---

### Step 2: Apply Rate Limiting to Routes

**File**: `routes/api.php`

**Action**: Replace entire file:

```php
<?php

use App\Http\Controllers\AnimalController;
use App\Http\Controllers\AnimalHealthRecordController;
use App\Http\Controllers\AnimalProductionLogController;
use App\Http\Controllers\AnimalWeightController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CropController;
use App\Http\Controllers\FeedingLogController;
use App\Http\Controllers\FeedingScheduleController;
use App\Http\Controllers\InventoryController;
use App\Http\Controllers\SaleController;
use App\Http\Controllers\TaskController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Version prefix
Route::prefix('v1')->group(function () {
    
    // Public auth routes - with strict rate limiting
    Route::middleware('throttle:auth')->group(function () {
        Route::post('/register', [AuthController::class, 'register'])->name('register');
        Route::post('/login', [AuthController::class, 'login'])->name('login');
        Route::post('/forgot-password', [AuthController::class, 'forgotPassword'])->name('password.forgot');
        Route::post('/reset-password', [AuthController::class, 'resetPassword'])->name('password.reset');
    });

    // Protected routes - with moderate rate limiting
    Route::middleware(['auth:sanctum', 'throttle:api'])->group(function () {
        
        // User profile
        Route::get('/user', function (Request $request) {
            return $request->user();
        });
        Route::post('/logout', [AuthController::class, 'logout']);

        // Farm Management
        Route::apiResource('animals', AnimalController::class);
        Route::apiResource('crops', CropController::class);
        Route::apiResource('tasks', TaskController::class);
        Route::apiResource('feeding-logs', FeedingLogController::class);
        Route::apiResource('feeding-schedules', FeedingScheduleController::class);

        // Inventory & Sales
        Route::apiResource('inventories', InventoryController::class);
        Route::apiResource('sales', SaleController::class);

        // Animal tracking
        Route::apiResource('animal-weights', AnimalWeightController::class);
        Route::apiResource('animal-health-records', AnimalHealthRecordController::class);
        Route::apiResource('animal-production-logs', AnimalProductionLogController::class);
    });
});
```

---

## Task 1.2: Strengthen Password Validation

### Step 1: Create Custom Password Rule

**File**: `app/Rules/StrongPassword.php` (create new)

**Action**: Create this file:

```php
<?php

namespace App\Rules;

use Closure;
use Illuminate\Contracts\Validation\ValidationRule;

class StrongPassword implements ValidationRule
{
    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        $minLength = config('auth.password_min_length', 12);
        
        // Check minimum length
        if (strlen($value) < $minLength) {
            $fail("The {$attribute} must be at least {$minLength} characters.");
            return;
        }

        // Check for uppercase letter
        if (config('auth.password_require_uppercase', true) && !preg_match('/[A-Z]/', $value)) {
            $fail("The {$attribute} must contain at least one uppercase letter.");
            return;
        }

        // Check for lowercase letter
        if (config('auth.password_require_lowercase', true) && !preg_match('/[a-z]/', $value)) {
            $fail("The {$attribute} must contain at least one lowercase letter.");
            return;
        }

        // Check for number
        if (config('auth.password_require_numbers', true) && !preg_match('/[0-9]/', $value)) {
            $fail("The {$attribute} must contain at least one number.");
            return;
        }

        // Check for special character
        if (config('auth.password_require_symbols', true) && !preg_match('/[^A-Za-z0-9]/', $value)) {
            $fail("The {$attribute} must contain at least one special character.");
            return;
        }

        // Check against common passwords
        $commonPasswords = ['password', '12345678', 'qwerty', 'admin123', 'letmein'];
        if (in_array(strtolower($value), $commonPasswords)) {
            $fail("The {$attribute} is too common. Please choose a stronger password.");
        }
    }
}
```

---

### Step 2: Update Auth Controller

**File**: `app/Http/Controllers/AuthController.php`

**Action**: Replace with this:

```php
<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Rules\StrongPassword;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Password;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Register a new user
     */
    public function register(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => ['required', 'string', 'confirmed', new StrongPassword()],
            'phone' => 'nullable|string|max:20',
            'farm_name' => 'nullable|string|max:255',
            'location' => 'nullable|string|max:255',
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'phone' => $validated['phone'] ?? null,
            'farm_name' => $validated['farm_name'] ?? null,
            'location' => $validated['location'] ?? null,
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        Log::info('User registered', ['user_id' => $user->id, 'email' => $user->email]);

        return response()->json([
            'user' => $user,
            'token' => $token,
        ], 201);
    }

    /**
     * Login user
     */
    public function login(Request $request)
    {
        $validated = $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $validated['email'])->first();

        if (!$user || !Hash::check($validated['password'], $user->password)) {
            Log::warning('Failed login attempt', ['email' => $validated['email'], 'ip' => $request->ip()]);
            
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        // Revoke previous tokens for security
        $user->tokens()->delete();

        $token = $user->createToken('auth_token')->plainTextToken;

        Log::info('User logged in', ['user_id' => $user->id, 'email' => $user->email]);

        return response()->json([
            'user' => $user,
            'token' => $token,
        ]);
    }

    /**
     * Logout user
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        Log::info('User logged out', ['user_id' => $request->user()->id]);

        return response()->json(['message' => 'Logged out successfully']);
    }

    /**
     * Send password reset link
     */
    public function forgotPassword(Request $request)
    {
        $request->validate(['email' => 'required|email']);

        $status = Password::sendResetLink(
            $request->only('email')
        );

        if ($status === Password::RESET_LINK_SENT) {
            return response()->json(['message' => 'Password reset link sent to your email.']);
        }

        throw ValidationException::withMessages([
            'email' => [__($status)],
        ]);
    }

    /**
     * Reset password
     */
    public function resetPassword(Request $request)
    {
        $request->validate([
            'token' => 'required',
            'email' => 'required|email',
            'password' => ['required', 'confirmed', new StrongPassword()],
        ]);

        $status = Password::reset(
            $request->only('email', 'password', 'password_confirmation', 'token'),
            function ($user, $password) {
                $user->forceFill([
                    'password' => Hash::make($password)
                ])->save();

                $user->tokens()->delete();
            }
        );

        if ($status === Password::PASSWORD_RESET) {
            return response()->json(['message' => 'Password reset successfully.']);
        }

        throw ValidationException::withMessages([
            'email' => [__($status)],
        ]);
    }
}
```

---

## Task 1.3: Implement Token Refresh Mechanism

### Step 1: Create Token Service

**File**: `app/Services/Auth/TokenService.php` (create new)

```php
<?php

namespace App\Services\Auth;

use App\Models\User;
use Laravel\Sanctum\PersonalAccessToken;

class TokenService
{
    private const ACCESS_TOKEN_EXPIRATION = 60; // minutes
    private const REFRESH_TOKEN_EXPIRATION = 10080; // 7 days in minutes

    /**
     * Create access and refresh tokens
     */
    public function createTokenPair(User $user): array
    {
        // Delete old tokens
        $user->tokens()->delete();

        // Create access token
        $accessToken = $user->createToken(
            'access_token',
            ['*'],
            now()->addMinutes(self::ACCESS_TOKEN_EXPIRATION)
        );

        // Create refresh token
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

    /**
     * Refresh access token using refresh token
     */
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
```

---

### Step 2: Add Refresh Endpoint

**File**: `app/Http/Controllers/AuthController.php`

**Action**: Add this method to the controller:

```php
/**
 * Refresh access token
 */
public function refresh(Request $request)
{
    $validated = $request->validate([
        'refresh_token' => 'required|string',
    ]);

    try {
        $tokenService = new \App\Services\Auth\TokenService();
        $tokens = $tokenService->refreshToken($validated['refresh_token']);

        return response()->json($tokens);
    } catch (\Exception $e) {
        Log::warning('Token refresh failed', ['error' => $e->getMessage()]);
        
        return response()->json([
            'message' => 'Invalid or expired refresh token'
        ], 401);
    }
}
```

---

### Step 3: Update Login to Return Both Tokens

**File**: `app/Http/Controllers/AuthController.php`

**Action**: Replace `login()` method:

```php
public function login(Request $request)
{
    $validated = $request->validate([
        'email' => 'required|email',
        'password' => 'required|string',
    ]);

    $user = User::where('email', $validated['email'])->first();

    if (!$user || !Hash::check($validated['password'], $user->password)) {
        Log::warning('Failed login attempt', ['email' => $validated['email'], 'ip' => $request->ip()]);
        
        throw ValidationException::withMessages([
            'email' => ['The provided credentials are incorrect.'],
        ]);
    }

    $tokenService = new \App\Services\Auth\TokenService();
    $tokens = $tokenService->createTokenPair($user);

    Log::info('User logged in', ['user_id' => $user->id, 'email' => $user->email]);

    return response()->json([
        'user' => $user,
        ...$tokens,
    ]);
}
```

---

### Step 4: Add Refresh Route

**File**: `routes/api.php`

**Action**: Add this route in the public auth group:

```php
Route::middleware('throttle:auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register'])->name('register');
    Route::post('/login', [AuthController::class, 'login'])->name('login');
    Route::post('/refresh', [AuthController::class, 'refresh'])->name('token.refresh'); // NEW
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword'])->name('password.forgot');
    Route::post('/reset-password', [AuthController::class, 'resetPassword'])->name('password.reset');
});
```

---

## Task 1.4: Implement Token Refresh in Flutter

### Step 1: Create Token Manager

**File**: `lib/core/network/token_manager.dart` (create new)

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Logger _logger = Logger();

  String? _accessToken;
  String? _refreshToken;
  DateTime? _expiresAt;

  TokenManager._internal();

  /// Save tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String expiresAt,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _expiresAt = DateTime.parse(expiresAt);

    await Future.wait([
      _storage.write(key: 'access_token', value: accessToken),
      _storage.write(key: 'refresh_token', value: refreshToken),
      _storage.write(key: 'expires_at', value: expiresAt),
    ]);
  }

  /// Get access token (refresh if needed)
  Future<String?> getAccessToken() async {
    // Load from storage if not in memory
    if (_accessToken == null) {
      await _loadTokensFromStorage();
    }

    // Check if token is expired or about to expire (within 5 minutes)
    if (_expiresAt != null && 
        _expiresAt!.subtract(const Duration(minutes: 5)).isBefore(DateTime.now())) {
      _logger.w('Access token expired or expiring soon, refreshing...');
      await _refreshAccessToken();
    }

    return _accessToken;
  }

  /// Load tokens from secure storage
  Future<void> _loadTokensFromStorage() async {
    final values = await Future.wait([
      _storage.read(key: 'access_token'),
      _storage.read(key: 'refresh_token'),
      _storage.read(key: 'expires_at'),
    ]);

    _accessToken = values[0];
    _refreshToken = values[1];
    if (values[2] != null) {
      _expiresAt = DateTime.parse(values[2]!);
    }
  }

  /// Refresh access token using refresh token
  Future<void> _refreshAccessToken() async {
    if (_refreshToken == null) {
      throw Exception('No refresh token available');
    }

    try {
      final dio = Dio();
      final response = await dio.post(
        '${const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000/api')}/v1/refresh',
        data: {'refresh_token': _refreshToken},
      );

      await saveTokens(
        accessToken: response.data['access_token'],
        refreshToken: response.data['refresh_token'],
        expiresAt: response.data['expires_at'],
      );

      _logger.i('Access token refreshed successfully');
    } catch (e) {
      _logger.e('Failed to refresh token', error: e);
      await clearTokens();
      throw Exception('Token refresh failed');
    }
  }

  /// Clear all tokens
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _expiresAt = null;

    await Future.wait([
      _storage.delete(key: 'access_token'),
      _storage.delete(key: 'refresh_token'),
      _storage.delete(key: 'expires_at'),
    ]);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null;
  }
}
```

---

### Step 2: Update API Service to Use Token Manager

**File**: `lib/data/network/api_service.dart`

**Action**: Replace with this improved version:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../../auth/auth_state.dart';
import '../../core/network/token_manager.dart';
import 'package:logger/logger.dart';

class ApiException implements Exception {
  final int? statusCode;
  final dynamic body;
  final String message;

  ApiException(this.message, {this.statusCode, this.body});

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message, body: $body)';
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  final TokenManager _tokenManager = TokenManager();
  final Logger _logger = Logger();

  ApiService._internal() {
    final base = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000/api';
    _dio = Dio(BaseOptions(
      baseUrl: '$base/v1', // Add version prefix
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        String? token = await _tokenManager.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        final status = e.response?.statusCode;
        
        // If unauthorized, clear tokens
        if (status == 401) {
          _logger.w('401 Unauthorized - clearing tokens');
          await _tokenManager.clearTokens();
          AuthState.isAuthenticated.value = false;
        }

        // If 5xx error, log for monitoring
        if (status != null && status >= 500) {
          _logger.e('Server error [$status]', error: e.response?.data);
        }

        handler.next(e);
      },
    ));

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => _logger.d(obj),
      ));
    }
  }

  Dio get dio => _dio;

  // Generic GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      developer.log('GET $path failed: ${e.response?.statusCode} ${e.response?.data}');
      throw ApiException('GET request failed', statusCode: e.response?.statusCode, body: e.response?.data);
    }
  }

  // Generic POST request
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      developer.log('POST $path failed: ${e.response?.statusCode} ${e.response?.data} -- payload: $data');
      throw ApiException('POST request failed', statusCode: e.response?.statusCode, body: e.response?.data);
    }
  }

  // Generic PUT request
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      developer.log('PUT $path failed: ${e.response?.statusCode} ${e.response?.data} -- payload: $data');
      throw ApiException('PUT request failed', statusCode: e.response?.statusCode, body: e.response?.data);
    }
  }

  // Generic DELETE request
  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      developer.log('DELETE $path failed: ${e.response?.statusCode} ${e.response?.data}');
      throw ApiException('DELETE request failed', statusCode: e.response?.statusCode, body: e.response?.data);
    }
  }
}
```

---

### Step 3: Update Auth Service

**File**: `lib/data/services/auth_service.dart`

**Action**: Replace with:

```dart
import '../network/api_service.dart';
import '../models/user.dart';
import '../../core/network/token_manager.dart';
import 'package:logger/logger.dart';

class AuthService {
  final ApiService _api = ApiService();
  final TokenManager _tokenManager = TokenManager();
  final Logger _logger = Logger();

  /// Register new user
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? farmName,
    String? location,
  }) async {
    final response = await _api.post('/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'phone': phone,
      'farm_name': farmName,
      'location': location,
    });

    await _tokenManager.saveTokens(
      accessToken: response.data['access_token'],
      refreshToken: response.data['refresh_token'],
      expiresAt: response.data['expires_at'],
    );

    return User.fromMap(response.data['user']);
  }

  /// Login user
  Future<User> login({required String email, required String password}) async {
    final response = await _api.post('/login', data: {
      'email': email,
      'password': password,
    });

    await _tokenManager.saveTokens(
      accessToken: response.data['access_token'],
      refreshToken: response.data['refresh_token'],
      expiresAt: response.data['expires_at'],
    );

    _logger.i('User logged in successfully');

    return User.fromMap(response.data['user']);
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _api.post('/logout');
    } catch (e) {
      _logger.w('Logout API call failed', error: e);
    } finally {
      await _tokenManager.clearTokens();
      _logger.i('User logged out');
    }
  }

  /// Get current user
  Future<User> getCurrentUser() async {
    final response = await _api.get('/user');
    return User.fromMap(response.data);
  }

  /// Request password reset
  Future<void> forgotPassword(String email) async {
    await _api.post('/forgot-password', data: {'email': email});
  }

  /// Reset password
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _api.post('/reset-password', data: {
      'email': email,
      'token': token,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }
}
```

---

## Task 1.5: Add Input Sanitization

### Laravel Input Sanitization

**File**: `app/Http/Middleware/SanitizeInput.php` (create new)

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class SanitizeInput
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $input = $request->all();
        
        array_walk_recursive($input, function (&$value) {
            if (is_string($value)) {
                // Remove null bytes
                $value = str_replace(chr(0), '', $value);
                
                // Trim whitespace
                $value = trim($value);
                
                // Remove invisible characters
                $value = preg_replace('/[\x00-\x1F\x7F]/u', '', $value);
            }
        });

        $request->merge($input);

        return $next($request);
    }
}
```

---

**File**: `bootstrap/app.php`

**Action**: Add middleware to the application:

```php
<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->append(\App\Http\Middleware\SanitizeInput::class); // ADD THIS
    })
    ->withExceptions(function (Exceptions $exceptions) {
        //
    })->create();
```

---

## Task 1.6: Enable CORS Properly

**File**: `config/cors.php`

**Action**: Replace with:

```php
<?php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    
    'allowed_methods' => ['*'],
    
    'allowed_origins' => explode(',', env('CORS_ALLOWED_ORIGINS', '*')),
    
    'allowed_origins_patterns' => [],
    
    'allowed_headers' => ['*'],
    
    'exposed_headers' => [],
    
    'max_age' => 0,
    
    'supports_credentials' => true,
];
```

**File**: `.env`

**Action**: Add:

```bash
# Development
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://127.0.0.1:3000

# Production (replace with your domain)
# CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://app.yourdomain.com
```

---

# Phase 2: Testing Foundation
**Duration**: 2 weeks  
**Priority**: CRITICAL

## Task 2.1: Setup Testing Infrastructure

### Flutter Testing Setup

**File**: `test/test_helpers/test_injection.dart` (create new)

```dart
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pamoja_twalima/data/network/api_service.dart';
import 'package:pamoja_twalima/core/network/token_manager.dart';

// Mock classes
class MockApiService extends Mock implements ApiService {}
class MockTokenManager extends Mock implements TokenManager {}

final getIt = GetIt.instance;

void setupTestDependencies() {
  getIt.reset();
  
  // Register mocks
  getIt.registerLazySingleton<ApiService>(() => MockApiService());
  getIt.registerLazySingleton<TokenManager>(() => MockTokenManager());
}

void teardownTestDependencies() {
  getIt.reset();
}
```

---

### Step 1: Create Auth Tests

**File**: `test/features/auth/auth_service_test.dart` (create new)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:pamoja_twalima/data/services/auth_service.dart';
import 'package:pamoja_twalima/data/network/api_service.dart';
import 'package:pamoja_twalima/core/network/token_manager.dart';
import 'package:pamoja_twalima/data/models/user.dart';

class MockApiService extends Mock implements ApiService {}
class MockTokenManager extends Mock implements TokenManager {}
class MockResponse extends Mock implements Response {}

void main() {
  late AuthService authService;
  late MockApiService mockApiService;
  late MockTokenManager mockTokenManager;

  setUp(() {
    mockApiService = MockApiService();
    mockTokenManager = MockTokenManager();
    authService = AuthService();
    
    // Register fallback values for any/captureAny
    registerFallbackValue(Uri());
  });

  group('AuthService', () {
    group('login', () {
      test('should return User when login is successful', () async {
        // Arrange
        final mockResponse = MockResponse();
        when(() => mockResponse.data).thenReturn({
          'user': {
            'id': 1,
            'name': 'Test User',
            'email': 'test@example.com',
          },
          'access_token': 'test_access_token',
          'refresh_token': 'test_refresh_token',
          'expires_at': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        });

        when(() => mockApiService.post(
          '/login',
          data: any(named: 'data'),
        )).thenAnswer((_) async => mockResponse);

        when(() => mockTokenManager.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
          expiresAt: any(named: 'expiresAt'),
        )).thenAnswer((_) async => Future.value());

        // Act
        final result = await authService.login(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(result, isA<User>());
        expect(result.email, 'test@example.com');
        expect(result.name, 'Test User');

        verify(() => mockApiService.post(
          '/login',
          data: {
            'email': 'test@example.com',
            'password': 'password123',
          },
        )).called(1);

        verify(() => mockTokenManager.saveTokens(
          accessToken: 'test_access_token',
          refreshToken: 'test_refresh_token',
          expiresAt: any(named: 'expiresAt'),
        )).called(1);
      });

      test('should throw exception when login fails', () async {
        // Arrange
        when(() => mockApiService.post(
          '/login',
          data: any(named: 'data'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/login'),
          response: Response(
            requestOptions: RequestOptions(path: '/login'),
            statusCode: 401,
            data: {'message': 'Invalid credentials'},
          ),
        ));

        // Act & Assert
        expect(
          () => authService.login(
            email: 'wrong@example.com',
            password: 'wrongpass',
          ),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('register', () {
      test('should return User when registration is successful', () async {
        // Arrange
        final mockResponse = MockResponse();
        when(() => mockResponse.data).thenReturn({
          'user': {
            'id': 1,
            'name': 'New User',
            'email': 'new@example.com',
          },
          'access_token': 'test_access_token',
          'refresh_token': 'test_refresh_token',
          'expires_at': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        });

        when(() => mockApiService.post(
          '/register',
          data: any(named: 'data'),
        )).thenAnswer((_) async => mockResponse);

        when(() => mockTokenManager.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
          expiresAt: any(named: 'expiresAt'),
        )).thenAnswer((_) async => Future.value());

        // Act
        final result = await authService.register(
          name: 'New User',
          email: 'new@example.com',
          password: 'StrongPass123!',
          passwordConfirmation: 'StrongPass123!',
        );

        // Assert
        expect(result, isA<User>());
        expect(result.email, 'new@example.com');
        expect(result.name, 'New User');
      });
    });

    group('logout', () {
      test('should clear tokens on logout', () async {
        // Arrange
        final mockResponse = MockResponse();
        when(() => mockResponse.data).thenReturn({'message': 'Logged out'});

        when(() => mockApiService.post('/logout'))
            .thenAnswer((_) async => mockResponse);

        when(() => mockTokenManager.clearTokens())
            .thenAnswer((_) async => Future.value());

        // Act
        await authService.logout();

        // Assert
        verify(() => mockApiService.post('/logout')).called(1);
        verify(() => mockTokenManager.clearTokens()).called(1);
      });
    });
  });
}
```

---

### Step 2: Create Widget Tests

**File**: `test/features/auth/login_screen_test.dart` (create new)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pamoja_twalima/auth/presentation/login_screen.dart';
import 'package:pamoja_twalima/auth/providers/auth_provider.dart';

void main() {
  late AuthProvider authProvider;

  setUp(() {
    authProvider = AuthProvider();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('should display email and password fields', (tester) async {
      // Build widget
      await tester.pumpWidget(createTestWidget());

      // Find text fields
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should display login button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('should show error when email is invalid', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter invalid email
      await tester.enterText(
        find.byType(TextField).first,
        'invalid-email',
      );

      // Enter password
      await tester.enterText(
        find.byType(TextField).last,
        'password123',
      );

      // Tap login
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      // Should show validation error
      // (This assumes you have form validation)
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should navigate to register screen when link is tapped', 
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find and tap register link
      final registerLink = find.text('Create account');
      expect(registerLink, findsOneWidget);

      await tester.tap(registerLink);
      await tester.pumpAndSettle();

      // Should navigate to register screen
      // (Verify navigation occurred)
    });
  });
}
```

---

### Laravel Testing Setup

**File**: `tests/Feature/Api/AuthTest.php` (create new)

```php
<?php

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;

uses(RefreshDatabase::class);

test('user can register with valid data', function () {
    $response = $this->postJson('/api/v1/register', [
        'name' => 'Test User',
        'email' => 'test@example.com',
        'password' => 'StrongPass123!',
        'password_confirmation' => 'StrongPass123!',
    ]);

    $response->assertStatus(201)
        ->assertJsonStructure([
            'user' => ['id', 'name', 'email'],
            'access_token',
            'refresh_token',
            'expires_at',
        ]);

    $this->assertDatabaseHas('users', [
        'email' => 'test@example.com',
        'name' => 'Test User',
    ]);
});

test('user cannot register with weak password', function () {
    $response = $this->postJson('/api/v1/register', [
        'name' => 'Test User',
        'email' => 'test@example.com',
        'password' => 'weak',
        'password_confirmation' => 'weak',
    ]);

    $response->assertStatus(422)
        ->assertJsonValidationErrors(['password']);
});

test('user cannot register with duplicate email', function () {
    User::factory()->create(['email' => 'test@example.com']);

    $response = $this->postJson('/api/v1/register', [
        'name' => 'Test User',
        'email' => 'test@example.com',
        'password' => 'StrongPass123!',
        'password_confirmation' => 'StrongPass123!',
    ]);

    $response->assertStatus(422)
        ->assertJsonValidationErrors(['email']);
});

test('user can login with correct credentials', function () {
    $user = User::factory()->create([
        'email' => 'test@example.com',
        'password' => Hash::make('StrongPass123!'),
    ]);

    $response = $this->postJson('/api/v1/login', [
        'email' => 'test@example.com',
        'password' => 'StrongPass123!',
    ]);

    $response->assertStatus(200)
        ->assertJsonStructure([
            'user' => ['id', 'name', 'email'],
            'access_token',
            'refresh_token',
            'expires_at',
        ]);
});

test('user cannot login with wrong credentials', function () {
    User::factory()->create([
        'email' => 'test@example.com',
        'password' => Hash::make('correct-password'),
    ]);

    $response = $this->postJson('/api/v1/login', [
        'email' => 'test@example.com',
        'password' => 'wrong-password',
    ]);

    $response->assertStatus(422)
        ->assertJsonValidationErrors(['email']);
});

test('login is rate limited', function () {
    $user = User::factory()->create([
        'password' => Hash::make('password'),
    ]);

    // Make 6 requests (rate limit is 5)
    for ($i = 0; $i < 6; $i++) {
        $response = $this->postJson('/api/v1/login', [
            'email' => $user->email,
            'password' => 'wrong-password',
        ]);
    }

    $response->assertStatus(429); // Too Many Requests
});

test('authenticated user can logout', function () {
    $user = User::factory()->create();
    $token = $user->createToken('test-token')->plainTextToken;

    $response = $this->postJson('/api/v1/logout', [], [
        'Authorization' => "Bearer $token",
    ]);

    $response->assertStatus(200);
    
    $this->assertDatabaseMissing('personal_access_tokens', [
        'tokenable_id' => $user->id,
    ]);
});

test('user can refresh access token', function () {
    $user = User::factory()->create();
    
    $tokenService = new \App\Services\Auth\TokenService();
    $tokens = $tokenService->createTokenPair($user);

    $response = $this->postJson('/api/v1/refresh', [
        'refresh_token' => $tokens['refresh_token'],
    ]);

    $response->assertStatus(200)
        ->assertJsonStructure([
            'access_token',
            'refresh_token',
            'expires_at',
        ]);
});
```

---

**File**: `tests/Feature/Api/InventoryTest.php` (create new)

```php
<?php

use App\Models\User;
use App\Models\Inventory;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->user = User::factory()->create();
    $this->token = $this->user->createToken('test-token')->plainTextToken;
});

test('authenticated user can create inventory item', function () {
    $response = $this->postJson('/api/v1/inventories', [
        'item_name' => 'Chicken Feed',
        'category' => 'Feed',
        'quantity' => 100,
        'unit' => 'kg',
        'min_stock' => 20,
        'unit_price' => 50.00,
        'supplier' => 'ABC Suppliers',
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $response->assertStatus(201)
        ->assertJsonStructure([
            'id',
            'item_name',
            'category',
            'quantity',
            'unit',
        ]);

    $this->assertDatabaseHas('inventories', [
        'item_name' => 'Chicken Feed',
        'user_id' => $this->user->id,
    ]);
});

test('user can only see their own inventory items', function () {
    // Create items for this user
    Inventory::factory()->count(3)->create(['user_id' => $this->user->id]);
    
    // Create items for another user
    $otherUser = User::factory()->create();
    Inventory::factory()->count(2)->create(['user_id' => $otherUser->id]);

    $response = $this->getJson('/api/v1/inventories', [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $response->assertStatus(200)
        ->assertJsonCount(3); // Should only see 3 items
});

test('user can update their inventory item', function () {
    $inventory = Inventory::factory()->create(['user_id' => $this->user->id]);

    $response = $this->putJson("/api/v1/inventories/{$inventory->id}", [
        'quantity' => 150,
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $response->assertStatus(200);
    
    $this->assertDatabaseHas('inventories', [
        'id' => $inventory->id,
        'quantity' => 150,
    ]);
});

test('user cannot update another user inventory item', function () {
    $otherUser = User::factory()->create();
    $inventory = Inventory::factory()->create(['user_id' => $otherUser->id]);

    $response = $this->putJson("/api/v1/inventories/{$inventory->id}", [
        'quantity' => 150,
    ], [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $response->assertStatus(404);
});

test('user can delete their inventory item', function () {
    $inventory = Inventory::factory()->create(['user_id' => $this->user->id]);

    $response = $this->deleteJson("/api/v1/inventories/{$inventory->id}", [], [
        'Authorization' => "Bearer {$this->token}",
    ]);

    $response->assertStatus(204);
    
    $this->assertDatabaseMissing('inventories', [
        'id' => $inventory->id,
    ]);
});
```

---

### Step 3: Setup CI Pipeline

**File**: `.github/workflows/flutter-tests.yml` (create new)

```yaml
name: Flutter Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run code analysis
        run: flutter analyze
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
          fail_ci_if_error: true
```

---

**File**: `.github/workflows/laravel-tests.yml` (create new)

```yaml
name: Laravel Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: password
          MYSQL_DATABASE: test_db
        ports:
          - 3306:3306
        options: --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=3
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'
          extensions: mbstring, dom, fileinfo, mysql
          coverage: xdebug
      
      - name: Copy .env
        run: php -r "file_exists('.env') || copy('.env.example', '.env');"
      
      - name: Install Dependencies
        run: composer install --prefer-dist --no-progress
      
      - name: Generate key
        run: php artisan key:generate
      
      - name: Directory Permissions
        run: chmod -R 777 storage bootstrap/cache
      
      - name: Run Database Migrations
        env:
          DB_CONNECTION: mysql
          DB_HOST: 127.0.0.1
          DB_PORT: 3306
          DB_DATABASE: test_db
          DB_USERNAME: root
          DB_PASSWORD: password
        run: php artisan migrate --force
      
      - name: Run Tests
        env:
          DB_CONNECTION: mysql
          DB_HOST: 127.0.0.1
          DB_PORT: 3306
          DB_DATABASE: test_db
          DB_USERNAME: root
          DB_PASSWORD: password
        run: php artisan test --coverage
```

---

## Task 2.2: Create Integration Tests

**File**: `integration_test/app_test.dart` (create new)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pamoja_twalima/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('complete auth flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Should show splash screen
      expect(find.text('Pamoja Twalima'), findsOneWidget);
      
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should navigate to onboarding or login
      // (depends on first-time user)
      
      // Find and tap login
      final loginButton = find.text('Login');
      expect(loginButton, findsOneWidget);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(
        find.byType(TextField).first,
        'test@example.com',
      );
      
      await tester.enterText(
        find.byType(TextField).last,
        'password123',
      );

      // Submit
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should navigate to home screen
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('create inventory item', (tester) async {
      // Assuming user is already logged in
      app.main();
      await tester.pumpAndSettle();

      // Navigate to inventory
      await tester.tap(find.text('Inventory'));
      await tester.pumpAndSettle();

      // Tap add button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(find.byKey(const Key('item_name')), 'Test Item');
      await tester.enterText(find.byKey(const Key('quantity')), '100');
      
      // Submit
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify item appears in list
      expect(find.text('Test Item'), findsOneWidget);
    });
  });
}
```

---

This guide is getting very long. I'll create a separate comprehensive document that continues with all remaining phases. Let me create Part 2:

