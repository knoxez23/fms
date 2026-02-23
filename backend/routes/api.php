<?php

use App\Http\Controllers\AnimalController;
use App\Http\Controllers\AnimalHealthRecordController;
use App\Http\Controllers\AnimalProductionLogController;
use App\Http\Controllers\AnimalWeightController;
use App\Http\Controllers\AuditEventController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CropController;
use App\Http\Controllers\CustomerController;
use App\Http\Controllers\FeedingLogController;
use App\Http\Controllers\FeedingScheduleController;
use App\Http\Controllers\HealthController;
use App\Http\Controllers\InventoryController;
use App\Http\Controllers\SaleController;
use App\Http\Controllers\StaffMemberController;
use App\Http\Controllers\SupplierController;
use App\Http\Controllers\TaskController;
use App\Http\Controllers\WeatherController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::get('/health', HealthController::class);

    Route::middleware('throttle:auth')->group(function () {
        Route::post('/register', [AuthController::class, 'register'])->name('register');
        Route::post('/login', [AuthController::class, 'login'])->name('login');
        Route::post('/refresh', [AuthController::class, 'refresh'])->name('token.refresh');
        Route::post('/forgot-password', [AuthController::class, 'forgotPassword'])->name('password.forgot');
        Route::post('/reset-password', [AuthController::class, 'resetPassword'])->name('password.reset');
    });

    Route::middleware(['auth:sanctum', 'throttle:api'])->group(function () {
        Route::get('/user', [AuthController::class, 'me']);
        Route::patch('/user', [AuthController::class, 'updateProfile']);

        Route::post('/logout', [AuthController::class, 'logout']);

        Route::apiResource('animals', AnimalController::class);
        Route::apiResource('crops', CropController::class);
        Route::apiResource('tasks', TaskController::class);
        Route::apiResource('feeding-logs', FeedingLogController::class);
        Route::apiResource('feeding-schedules', FeedingScheduleController::class);
        Route::delete('inventories/by-client/{clientUuid}', [InventoryController::class, 'destroyByClientUuid']);
        Route::apiResource('inventories', InventoryController::class);
        Route::apiResource('sales', SaleController::class);
        Route::apiResource('suppliers', SupplierController::class);
        Route::apiResource('customers', CustomerController::class);
        Route::apiResource('staff-members', StaffMemberController::class);
        Route::get('audit-events', [AuditEventController::class, 'index']);
        Route::get('weather', [WeatherController::class, 'index']);

        Route::apiResource('animal-weights', AnimalWeightController::class);
        Route::apiResource('animal-health-records', AnimalHealthRecordController::class);
        Route::apiResource('animal-production-logs', AnimalProductionLogController::class);
    });
});
