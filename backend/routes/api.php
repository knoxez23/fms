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


Route::post('/register', [AuthController::class, 'register'])->name('register');
Route::post('/login', [AuthController::class, 'login'])->name('login');

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    Route::post('/logout', [AuthController::class, 'logout']);

    Route::apiResource('animals', AnimalController::class);
    Route::apiResource('crops', CropController::class);
    Route::apiResource('tasks', TaskController::class);
    Route::apiResource('feeding-logs', FeedingLogController::class);
    Route::apiResource('feeding-schedules', FeedingScheduleController::class);
    Route::apiResource('inventories', InventoryController::class);
    Route::apiResource('sales', SaleController::class);

    // New resources
    Route::apiResource('animal-weights', AnimalWeightController::class);
    Route::apiResource('animal-health-records', AnimalHealthRecordController::class);
    Route::apiResource('animal-production-logs', AnimalProductionLogController::class);
});