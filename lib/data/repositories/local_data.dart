import 'dart:convert';
import 'package:pamoja_twalima/core/services/local_session_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pamoja_twalima/features/home/domain/entities/dashboard_data.dart';
import '../database/database_helper.dart';
import '../models/animal.dart';
import '../models/crop.dart';
import '../models/task.dart';
import '../models/feeding_schedule.dart';
import '../models/feeding_log.dart';
import '../models/animal_health_record.dart';

class LocalData {
  static final DatabaseHelper _dbHelper = DatabaseHelper();
  static final LocalSessionService _localSessionService = LocalSessionService();
  static const String _rationLabelPrefix = 'measure_label:';

  static Future<int?> _getActiveUserId() async {
    return _localSessionService.getActiveUserId();
  }

  static Future<Map<String, dynamic>> _attachActiveUserId(
    Map<String, dynamic> row,
  ) async {
    if (row.containsKey('user_id') && row['user_id'] != null) {
      return row;
    }
    final activeUserId = await _localSessionService.getActiveUserId();
    if (activeUserId == null) return row;
    return {
      ...row,
      'user_id': activeUserId,
    };
  }

  static Future<Map<String, dynamic>> getFarmSummary() async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();

    // Get crop count
    final cropResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM crops${activeUserId == null ? '' : ' WHERE user_id = ?'}',
      activeUserId == null ? null : [activeUserId],
    );
    final cropCount = Sqflite.firstIntValue(cropResult) ?? 0;

    // Get animal count
    final animalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM animals${activeUserId == null ? '' : ' WHERE user_id = ?'}',
      activeUserId == null ? null : [activeUserId],
    );
    final animalCount = Sqflite.firstIntValue(animalResult) ?? 0;

    // Get inventory count
    final inventoryResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM inventory${activeUserId == null ? '' : ' WHERE user_id = ?'}',
      activeUserId == null ? null : [activeUserId],
    );
    final inventoryCount = Sqflite.firstIntValue(inventoryResult) ?? 0;

    // Get pending tasks count
    final tasksResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE status != ?${activeUserId == null ? '' : ' AND user_id = ?'}',
      activeUserId == null ? ['completed'] : ['completed', activeUserId],
    );
    final pendingTasksCount = Sqflite.firstIntValue(tasksResult) ?? 0;

    // Get today's sales
    final today = DateTime.now().toIso8601String().split('T')[0];
    final salesResult = await db.rawQuery(
        'SELECT SUM(total_amount) as total FROM sales WHERE DATE(sale_date) = ?${activeUserId == null ? '' : ' AND user_id = ?'}',
        activeUserId == null ? [today] : [today, activeUserId]);
    final salesToday = (salesResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // Get this month's sales
    final firstDayOfMonth =
        DateTime(DateTime.now().year, DateTime.now().month, 1)
            .toIso8601String()
            .split('T')[0];
    final monthlySalesResult = await db.rawQuery(
        'SELECT SUM(total_amount) as total FROM sales WHERE DATE(sale_date) >= ?${activeUserId == null ? '' : ' AND user_id = ?'}',
        activeUserId == null
            ? [firstDayOfMonth]
            : [firstDayOfMonth, activeUserId]);
    final monthlySales =
        (monthlySalesResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final expensesTodayResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE DATE(expense_date) = ?${activeUserId == null ? '' : ' AND user_id = ?'}',
      activeUserId == null ? [today] : [today, activeUserId],
    );
    final expensesToday =
        (expensesTodayResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final monthlyExpensesResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE DATE(expense_date) >= ?${activeUserId == null ? '' : ' AND user_id = ?'}',
      activeUserId == null
          ? [firstDayOfMonth]
          : [firstDayOfMonth, activeUserId],
    );
    final monthlyExpenses =
        (monthlyExpensesResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final trailing7DaySalesResult = await db.rawQuery(
      'SELECT SUM(total_amount) as total FROM sales WHERE DATE(sale_date) >= DATE(?)${activeUserId == null ? '' : ' AND user_id = ?'}',
      activeUserId == null
          ? [nextDateIso(-6)]
          : [nextDateIso(-6), activeUserId],
    );
    final trailing7DaySales =
        (trailing7DaySalesResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final trailing7DayExpensesResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE DATE(expense_date) >= DATE(?)${activeUserId == null ? '' : ' AND user_id = ?'}',
      activeUserId == null
          ? [nextDateIso(-6)]
          : [nextDateIso(-6), activeUserId],
    );
    final trailing7DayExpenses =
        (trailing7DayExpensesResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final lowStockResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM inventory WHERE min_stock > 0 AND quantity <= min_stock${activeUserId == null ? '' : ' AND user_id = ?'}',
      activeUserId == null ? null : [activeUserId],
    );
    final lowStockItems = Sqflite.firstIntValue(lowStockResult) ?? 0;

    final restockCostResult = await db.rawQuery(
      '''
      SELECT SUM(
        CASE
          WHEN COALESCE(min_stock, 0) > COALESCE(quantity, 0)
            AND unit_price IS NOT NULL
          THEN (COALESCE(min_stock, 0) - COALESCE(quantity, 0)) * unit_price
          ELSE 0
        END
      ) AS total
      FROM inventory
      ${activeUserId == null ? '' : 'WHERE user_id = ?'}
      ''',
      activeUserId == null ? null : [activeUserId],
    );
    final restockCostEstimate =
        (restockCostResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final productionTodayRows = await db.rawQuery(
      '''
      SELECT
        SUM(CASE WHEN LOWER(COALESCE(production_type, '')) = 'milk' THEN COALESCE(quantity, 0) ELSE 0 END) AS milk_total,
        SUM(CASE WHEN LOWER(COALESCE(production_type, '')) = 'eggs' THEN COALESCE(quantity, 0) ELSE 0 END) AS eggs_total
      FROM production_logs
      WHERE DATE(date_produced) = ?
      ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null ? [today] : [today, activeUserId],
    );
    final milkToday =
        (productionTodayRows.first['milk_total'] as num?)?.toDouble() ?? 0.0;
    final eggsToday =
        (productionTodayRows.first['eggs_total'] as num?)?.toDouble() ?? 0.0;
    final productionValueToday = (milkToday * 55.0) + (eggsToday * 15.0);

    final milkTrendRows = await db.rawQuery(
      '''
      SELECT
        SUM(CASE WHEN DATE(date_produced) >= DATE(?) THEN COALESCE(quantity, 0) ELSE 0 END) AS current_total,
        SUM(CASE WHEN DATE(date_produced) >= DATE(?) AND DATE(date_produced) < DATE(?) THEN COALESCE(quantity, 0) ELSE 0 END) AS previous_total
      FROM production_logs
      WHERE LOWER(COALESCE(production_type, '')) = 'milk'
      ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null
          ? [nextDateIso(-6), nextDateIso(-13), nextDateIso(-6)]
          : [nextDateIso(-6), nextDateIso(-13), nextDateIso(-6), activeUserId],
    );
    final milkCurrent7Days =
        (milkTrendRows.first['current_total'] as num?)?.toDouble() ?? 0.0;
    final milkPrevious7Days =
        (milkTrendRows.first['previous_total'] as num?)?.toDouble() ?? 0.0;

    final eggTrendRows = await db.rawQuery(
      '''
      SELECT
        SUM(CASE WHEN DATE(date_produced) >= DATE(?) THEN COALESCE(quantity, 0) ELSE 0 END) AS current_total,
        SUM(CASE WHEN DATE(date_produced) >= DATE(?) AND DATE(date_produced) < DATE(?) THEN COALESCE(quantity, 0) ELSE 0 END) AS previous_total
      FROM production_logs
      WHERE LOWER(COALESCE(production_type, '')) = 'eggs'
      ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null
          ? [nextDateIso(-6), nextDateIso(-13), nextDateIso(-6)]
          : [nextDateIso(-6), nextDateIso(-13), nextDateIso(-6), activeUserId],
    );
    final eggsCurrent7Days =
        (eggTrendRows.first['current_total'] as num?)?.toDouble() ?? 0.0;
    final eggsPrevious7Days =
        (eggTrendRows.first['previous_total'] as num?)?.toDouble() ?? 0.0;

    final outputSalesTodayRows = await db.rawQuery(
      '''
      SELECT
        SUM(CASE WHEN LOWER(COALESCE(product_name, '')) = 'milk' THEN COALESCE(quantity, 0) ELSE 0 END) AS milk_sold,
        SUM(CASE WHEN LOWER(COALESCE(product_name, '')) = 'eggs' THEN COALESCE(quantity, 0) ELSE 0 END) AS eggs_sold
      FROM sales
      WHERE DATE(sale_date) = ?
      ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null ? [today] : [today, activeUserId],
    );
    final milkSoldToday =
        (outputSalesTodayRows.first['milk_sold'] as num?)?.toDouble() ?? 0.0;
    final eggsSoldToday =
        (outputSalesTodayRows.first['eggs_sold'] as num?)?.toDouble() ?? 0.0;

    final outputStockRows = await db.rawQuery(
      '''
      SELECT
        SUM(
          CASE
            WHEN LOWER(COALESCE(item_name, '')) = 'milk'
              OR (LOWER(COALESCE(category, '')) = 'dairy' AND LOWER(COALESCE(item_name, '')) LIKE '%milk%')
            THEN MAX(COALESCE(quantity, 0) - COALESCE(reserved_quantity, 0), 0)
            ELSE 0
          END
        ) AS milk_stock,
        SUM(
          CASE
            WHEN LOWER(COALESCE(item_name, '')) = 'eggs'
              OR (LOWER(COALESCE(category, '')) = 'poultry' AND LOWER(COALESCE(item_name, '')) LIKE '%egg%')
            THEN MAX(COALESCE(quantity, 0) - COALESCE(reserved_quantity, 0), 0)
            ELSE 0
          END
        ) AS eggs_stock,
        SUM(
          CASE
            WHEN (
              LOWER(COALESCE(item_name, '')) = 'milk'
              OR LOWER(COALESCE(item_name, '')) = 'eggs'
              OR (LOWER(COALESCE(category, '')) = 'dairy' AND LOWER(COALESCE(item_name, '')) LIKE '%milk%')
              OR (LOWER(COALESCE(category, '')) = 'poultry' AND LOWER(COALESCE(item_name, '')) LIKE '%egg%')
            )
            THEN COALESCE(total_value, COALESCE(unit_price, 0) * COALESCE(quantity, 0))
            ELSE 0
          END
        ) AS output_stock_value
      FROM inventory
      WHERE MAX(COALESCE(quantity, 0) - COALESCE(reserved_quantity, 0), 0) > 0
      ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null ? null : [activeUserId],
    );
    final milkStockOnHand =
        (outputStockRows.first['milk_stock'] as num?)?.toDouble() ?? 0.0;
    final eggsStockOnHand =
        (outputStockRows.first['eggs_stock'] as num?)?.toDouble() ?? 0.0;
    final outputStockValue =
        (outputStockRows.first['output_stock_value'] as num?)?.toDouble() ??
            0.0;
    final unsoldMilkToday =
        (milkToday - milkSoldToday) > 0 ? (milkToday - milkSoldToday) : 0.0;
    final unsoldEggsToday =
        (eggsToday - eggsSoldToday) > 0 ? (eggsToday - eggsSoldToday) : 0.0;

    final outputStockItems = await db.query(
      'inventory',
      columns: [
        'item_name',
        'lot_code',
        'category',
        'quantity',
        'reserved_quantity',
        'unit',
        'expiry_date',
        'freshness_hours',
        'last_restock',
        'last_updated',
      ],
      where: activeUserId == null
          ? 'MAX(COALESCE(quantity, 0) - COALESCE(reserved_quantity, 0), 0) > 0'
          : 'MAX(COALESCE(quantity, 0) - COALESCE(reserved_quantity, 0), 0) > 0 AND user_id = ?',
      whereArgs: activeUserId == null ? null : [activeUserId],
    );
    final freshnessNow = DateTime.now();
    double oldestFreshOutputAgeHours = 0;
    var freshnessRiskCount = 0;
    String freshnessPriorityLabel = '';
    for (final row in outputStockItems) {
      final normalized = Map<String, Object?>.from(row);
      if (!_isMilkInventoryRow(normalized) && !_isEggInventoryRow(normalized)) {
        continue;
      }
      final quantity = ((normalized['quantity'] as num?)?.toDouble() ?? 0.0) -
          ((normalized['reserved_quantity'] as num?)?.toDouble() ?? 0.0);
      if (quantity <= 0) continue;
      final timestampValue =
          (normalized['last_restock'] ?? normalized['last_updated'])
              ?.toString();
      final timestamp = timestampValue == null
          ? null
          : DateTime.tryParse(timestampValue)?.toLocal();
      final expiryValue = normalized['expiry_date']?.toString();
      final expiry = expiryValue == null
          ? null
          : DateTime.tryParse(expiryValue)?.toLocal();
      final freshnessHours =
          (normalized['freshness_hours'] as num?)?.toDouble();
      final ageHours = _ageInHours(timestamp, freshnessNow);
      if (ageHours > oldestFreshOutputAgeHours) {
        oldestFreshOutputAgeHours = ageHours;
        freshnessPriorityLabel =
            'Sell ${_formatStockQuantity(quantity, (normalized['unit'] ?? 'units').toString())} ${(normalized['item_name'] ?? 'output').toString().toLowerCase()}${(normalized['lot_code'] ?? '').toString().trim().isEmpty ? '' : ' from lot ${(normalized['lot_code'] ?? '').toString().trim()}'} first';
      }
      final riskThresholdHours =
          freshnessHours ?? (_isMilkInventoryRow(normalized) ? 18.0 : 72.0);
      final isExpired = expiry != null && !expiry.isAfter(freshnessNow);
      if (isExpired || ageHours >= riskThresholdHours) {
        freshnessRiskCount++;
      }
    }

    final pendingCollectionsResult = await db.rawQuery(
      '''
      SELECT
        COUNT(*) as sale_count,
        SUM(COALESCE(total_amount, 0)) as total
      FROM sales
      WHERE LOWER(COALESCE(payment_status, 'pending')) != 'paid'
      ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null ? null : [activeUserId],
    );
    final pendingCollectionsCount =
        (pendingCollectionsResult.first['sale_count'] as num?)?.toInt() ?? 0;
    final pendingCollectionsValue =
        (pendingCollectionsResult.first['total'] as num?)?.toDouble() ?? 0.0;
    final collectionsRatio =
        monthlySales <= 0 ? 0.0 : pendingCollectionsValue / monthlySales;

    final revenueByTypeRows = await db.rawQuery(
      '''
      SELECT LOWER(COALESCE(type, 'other')) as type_key, SUM(COALESCE(total_amount, 0)) as total
      FROM sales
      ${activeUserId == null ? '' : 'WHERE user_id = ?'}
      GROUP BY LOWER(COALESCE(type, 'other'))
      ''',
      activeUserId == null ? null : [activeUserId],
    );
    final revenueByType = <String, double>{
      for (final row in revenueByTypeRows)
        (row['type_key'] ?? 'other').toString():
            (row['total'] as num?)?.toDouble() ?? 0.0,
    };
    final dairyRevenueMonth = revenueByType['dairy'] ?? 0.0;
    final poultryRevenueMonth = revenueByType['poultry'] ?? 0.0;
    final livestockRevenueMonth = revenueByType['livestock'] ?? 0.0;
    final otherRevenueMonth = revenueByType['other'] ?? 0.0;

    final expenseByCategoryRows = await db.rawQuery(
      '''
      SELECT LOWER(COALESCE(category, 'other')) as category_key, SUM(COALESCE(amount, 0)) as total
      FROM expenses
      ${activeUserId == null ? '' : 'WHERE user_id = ?'}
      GROUP BY LOWER(COALESCE(category, 'other'))
      ''',
      activeUserId == null ? null : [activeUserId],
    );
    final expenseByCategory = <String, double>{
      for (final row in expenseByCategoryRows)
        (row['category_key'] ?? 'other').toString():
            (row['total'] as num?)?.toDouble() ?? 0.0,
    };
    final feedCostsMonth = _sumMapValues(expenseByCategory, const {
      'feed',
      'animal feed',
      'feed cost',
    });
    final vetCostsMonth = _sumMapValues(expenseByCategory, const {
      'vet',
      'veterinary',
      'animal health',
      'treatment',
      'medicine',
    });
    final cropCostsMonth = _sumMapValues(expenseByCategory, const {
      'seeds',
      'fertilizers',
      'fertilizer',
      'chemicals',
      'crop input',
    });
    final laborCostsMonth = _sumMapValues(expenseByCategory, const {
      'labor',
      'labour',
      'wages',
      'casual labor',
    });

    final todaysFeedingResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM feeding_schedules
      WHERE completed = 0
        AND LOWER(COALESCE(time_of_day, '')) IN ('morning', 'afternoon', 'evening')
        AND (start_date IS NULL OR DATE(start_date) <= DATE(?))
        AND (end_date IS NULL OR DATE(end_date) >= DATE(?))
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null ? [today, today] : [today, today, activeUserId],
    );
    final todaysFeedings = Sqflite.firstIntValue(todaysFeedingResult) ?? 0;

    final feedingLogsTodayResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM feeding_logs
      WHERE DATE(fed_at) = DATE(?)
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null ? [today] : [today, activeUserId],
    );
    final feedingLogsToday = Sqflite.firstIntValue(feedingLogsTodayResult) ?? 0;
    final missedFeedingsToday = todaysFeedings > feedingLogsToday
        ? (todaysFeedings - feedingLogsToday)
        : 0;

    final todaysFeedingPreviewRows = await db.rawQuery(
      '''
      SELECT time_of_day, notes, quantity, unit
      FROM feeding_schedules
      WHERE completed = 0
        AND LOWER(COALESCE(time_of_day, '')) IN ('morning', 'afternoon', 'evening')
        AND (start_date IS NULL OR DATE(start_date) <= DATE(?))
        AND (end_date IS NULL OR DATE(end_date) >= DATE(?))
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ORDER BY CASE LOWER(COALESCE(time_of_day, ''))
        WHEN 'morning' THEN 1
        WHEN 'afternoon' THEN 2
        WHEN 'evening' THEN 3
        ELSE 4
      END ASC
      LIMIT 3
      ''',
      activeUserId == null ? [today, today] : [today, today, activeUserId],
    );
    final todaysFeedingPreview = todaysFeedingPreviewRows
        .map((row) {
          final timeOfDay = (row['time_of_day'] ?? 'Feed').toString();
          final rationLabel = _extractRationLabel(row['notes']?.toString());
          if (rationLabel.isNotEmpty) {
            return '$timeOfDay: $rationLabel';
          }
          final quantity = (row['quantity'] as num?)?.toDouble() ?? 0;
          final unit = (row['unit'] ?? 'units').toString();
          final quantityText = quantity == quantity.roundToDouble()
              ? quantity.toInt().toString()
              : quantity.toStringAsFixed(1);
          return '$timeOfDay: $quantityText $unit';
        })
        .where((item) => item.trim().isNotEmpty)
        .join(' • ');

    final setupTasks7dResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM tasks
      WHERE status != ?
        AND LOWER(COALESCE(source_event_type, '')) = 'setup'
        AND due_date IS NOT NULL
        AND DATE(due_date) <= DATE(?)
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null
          ? ['completed', nextDateIso(7)]
          : ['completed', nextDateIso(7), activeUserId],
    );
    final setupTasksNext7Days = Sqflite.firstIntValue(setupTasks7dResult) ?? 0;

    final setupTasks30dResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM tasks
      WHERE status != ?
        AND LOWER(COALESCE(source_event_type, '')) = 'setup'
        AND due_date IS NOT NULL
        AND DATE(due_date) <= DATE(?)
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null
          ? ['completed', nextDateIso(30)]
          : ['completed', nextDateIso(30), activeUserId],
    );
    final setupTasksNext30Days =
        Sqflite.firstIntValue(setupTasks30dResult) ?? 0;

    final plantedCropsResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM crops
      WHERE LOWER(COALESCE(status, '')) IN ('growing', 'planted')
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null ? null : [activeUserId],
    );
    final activeFieldCrops = Sqflite.firstIntValue(plantedCropsResult) ?? 0;

    final productionReviewResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM tasks
      WHERE status != ?
        AND LOWER(COALESCE(source_event_type, '')) = 'setup'
        AND due_date IS NOT NULL
        AND (
          LOWER(COALESCE(title, '')) LIKE '%production review%'
          OR LOWER(COALESCE(title, '')) LIKE '%feed efficiency%'
          OR LOWER(COALESCE(title, '')) LIKE '%growth review%'
          OR LOWER(COALESCE(title, '')) LIKE '%market timing%'
        )
        AND DATE(due_date) <= DATE(?)
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null
          ? ['completed', nextDateIso(7)]
          : ['completed', nextDateIso(7), activeUserId],
    );
    final productionReviewsNext7Days =
        Sqflite.firstIntValue(productionReviewResult) ?? 0;

    final harvestReadyResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM crops
      WHERE expected_harvest_date IS NOT NULL
        AND LOWER(COALESCE(status, '')) != 'harvested'
        AND DATE(expected_harvest_date) <= DATE(?)
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null
          ? [nextDateIso(14)]
          : [nextDateIso(14), activeUserId],
    );
    final harvestReadyCrops = Sqflite.firstIntValue(harvestReadyResult) ?? 0;

    final overdueTasksResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM tasks
      WHERE status != ?
        AND due_date IS NOT NULL
        AND DATE(due_date) < DATE(?)
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null
          ? ['completed', today]
          : ['completed', today, activeUserId],
    );
    final overdueTasks = Sqflite.firstIntValue(overdueTasksResult) ?? 0;

    final dueTodayTasksResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM tasks
      WHERE status != ?
        AND due_date IS NOT NULL
        AND DATE(due_date) = DATE(?)
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null
          ? ['completed', today]
          : ['completed', today, activeUserId],
    );
    final dueTodayTasks = Sqflite.firstIntValue(dueTodayTasksResult) ?? 0;

    final dueThisWeekTasksResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM tasks
      WHERE status != ?
        AND due_date IS NOT NULL
        AND DATE(due_date) > DATE(?)
        AND DATE(due_date) <= DATE(?)
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null
          ? ['completed', today, nextDateIso(7)]
          : ['completed', today, nextDateIso(7), activeUserId],
    );
    final dueThisWeekTasks = Sqflite.firstIntValue(dueThisWeekTasksResult) ?? 0;

    final approvalPendingTasksResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM tasks
      WHERE status != ?
        AND approval_required = 1
        AND LOWER(COALESCE(approval_status, 'pending')) = 'pending'
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null ? ['completed'] : ['completed', activeUserId],
    );
    final approvalPendingTasks =
        Sqflite.firstIntValue(approvalPendingTasksResult) ?? 0;

    final harvestPrepTaskResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM tasks
      WHERE status != ?
        AND (
          LOWER(COALESCE(title, '')) LIKE '%harvest%'
          OR LOWER(COALESCE(title, '')) LIKE '%stock%'
          OR LOWER(COALESCE(title, '')) LIKE '%market%'
        )
        AND due_date IS NOT NULL
        AND DATE(due_date) <= DATE(?)
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null
          ? ['completed', nextDateIso(14)]
          : ['completed', nextDateIso(14), activeUserId],
    );
    final harvestPrepTasks = Sqflite.firstIntValue(harvestPrepTaskResult) ?? 0;
    final harvestPrepGap = harvestReadyCrops > harvestPrepTasks
        ? (harvestReadyCrops - harvestPrepTasks)
        : 0;

    final feedGapResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM inventory
      WHERE LOWER(COALESCE(category, '')) = 'animal feed'
        AND min_stock > 0
        AND quantity <= min_stock
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null ? null : [activeUserId],
    );
    final feedReadinessGaps = Sqflite.firstIntValue(feedGapResult) ?? 0;

    final cropInputGapResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM inventory
      WHERE LOWER(COALESCE(category, '')) IN ('seeds', 'fertilizers', 'chemicals')
        AND min_stock > 0
        AND quantity <= min_stock
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null ? null : [activeUserId],
    );
    final cropInputGaps = Sqflite.firstIntValue(cropInputGapResult) ?? 0;
    final recentTreatmentRows = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM animal_health_records
      WHERE treated_at IS NOT NULL
        AND DATE(treated_at) >= DATE(?)
        AND LOWER(COALESCE(type, '')) IN ('treatment', 'vaccination', 'vaccine', 'deworming')
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null
          ? [nextDateIso(-3)]
          : [nextDateIso(-3), activeUserId],
    );
    final treatmentFollowUps =
        Sqflite.firstIntValue(recentTreatmentRows) ?? 0;
    final breedingDueRows = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM breeding_records
      WHERE LOWER(COALESCE(status, 'scheduled')) != 'completed'
        AND expected_birth_date IS NOT NULL
        AND DATE(expected_birth_date) <= DATE(?)
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null
          ? [nextDateIso(21)]
          : [nextDateIso(21), activeUserId],
    );
    final breedingReviewsDue = Sqflite.firstIntValue(breedingDueRows) ?? 0;
    final cropStageRows = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM crops
      WHERE LOWER(COALESCE(status, '')) IN ('growing', 'planted', 'flowering')
        AND planted_date IS NOT NULL
        AND DATE(planted_date) <= DATE(?)
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null
          ? [nextDateIso(-21)]
          : [nextDateIso(-21), activeUserId],
    );
    final cropStageReviewsDue = Sqflite.firstIntValue(cropStageRows) ?? 0;
    final enterpriseFocus = _enterpriseFocus(
      dairyRevenueMonth: dairyRevenueMonth,
      poultryRevenueMonth: poultryRevenueMonth,
      livestockRevenueMonth: livestockRevenueMonth,
      otherRevenueMonth: otherRevenueMonth,
      milkCurrent7Days: milkCurrent7Days,
      eggsCurrent7Days: eggsCurrent7Days,
      activeFieldCrops: activeFieldCrops,
    );
    final milkTrendBand = _trendBand(milkCurrent7Days, milkPrevious7Days);
    final eggsTrendBand = _trendBand(eggsCurrent7Days, eggsPrevious7Days);
    final costDisciplineBand = _costDisciplineBand(
      monthlySales: monthlySales,
      monthlyExpenses: monthlyExpenses,
      feedCostsMonth: feedCostsMonth,
      cropCostsMonth: cropCostsMonth,
    );
    final collectionsDisciplineBand =
        _collectionsDisciplineBand(collectionsRatio);

    final reminderSignals = <String>[
      if (feedReadinessGaps > 0)
        '$feedReadinessGaps feed gap${feedReadinessGaps == 1 ? '' : 's'}',
      if (cropInputGaps > 0)
        '$cropInputGaps crop input gap${cropInputGaps == 1 ? '' : 's'}',
      if (productionReviewsNext7Days > 0)
        '$productionReviewsNext7Days production review${productionReviewsNext7Days == 1 ? '' : 's'}',
      if (harvestReadyCrops > 0)
        '$harvestReadyCrops harvest-ready crop${harvestReadyCrops == 1 ? '' : 's'}',
      if (pendingCollectionsCount > 0)
        '$pendingCollectionsCount unpaid sale${pendingCollectionsCount == 1 ? '' : 's'}',
      if (freshnessRiskCount > 0)
        '$freshnessRiskCount fresh output lot${freshnessRiskCount == 1 ? '' : 's'} to move now',
      if (breedingReviewsDue > 0)
        '$breedingReviewsDue breeding follow-up${breedingReviewsDue == 1 ? '' : 's'} due',
      if (treatmentFollowUps > 0)
        '$treatmentFollowUps treatment follow-up${treatmentFollowUps == 1 ? '' : 's'} to review',
    ];
    final todayAgendaItems = <String>[
      if (overdueTasks > 0)
        '$overdueTasks overdue task${overdueTasks == 1 ? '' : 's'}',
      if (dueTodayTasks > 0)
        '$dueTodayTasks task${dueTodayTasks == 1 ? '' : 's'} due today',
      if (missedFeedingsToday > 0)
        '$missedFeedingsToday feeding session${missedFeedingsToday == 1 ? '' : 's'} still unlogged',
      if (approvalPendingTasks > 0)
        '$approvalPendingTasks task${approvalPendingTasks == 1 ? '' : 's'} waiting approval',
      if (pendingCollectionsCount > 0)
        '$pendingCollectionsCount collection${pendingCollectionsCount == 1 ? '' : 's'} to follow up',
      if (breedingReviewsDue > 0)
        '$breedingReviewsDue breeding review${breedingReviewsDue == 1 ? '' : 's'} due',
    ];
    final thisWeekFocusItems = <String>[
      if (dueThisWeekTasks > 0)
        '$dueThisWeekTasks task${dueThisWeekTasks == 1 ? '' : 's'} due this week',
      if (productionReviewsNext7Days > 0)
        '$productionReviewsNext7Days production review${productionReviewsNext7Days == 1 ? '' : 's'} to run',
      if (harvestReadyCrops > 0)
        '$harvestReadyCrops crop${harvestReadyCrops == 1 ? '' : 's'} entering harvest window',
      if (setupTasksNext7Days > 0)
        '$setupTasksNext7Days setup task${setupTasksNext7Days == 1 ? '' : 's'} due soon',
      if (cropStageReviewsDue > 0)
        '$cropStageReviewsDue crop block${cropStageReviewsDue == 1 ? '' : 's'} need timing review',
      if (treatmentFollowUps > 0)
        '$treatmentFollowUps treatment response check${treatmentFollowUps == 1 ? '' : 's'} this week',
    ];
    final smartReminderPreview = reminderSignals.take(3).join(' • ');
    final monthlyNetCashFlow = monthlySales - monthlyExpenses;
    final projectedCashBuffer =
        monthlyNetCashFlow + pendingCollectionsValue - restockCostEstimate;
    final adviceItems = <String>[
      if (missedFeedingsToday > 0)
        'Log feeding as it happens so feed usage, animal care, and costs stay accurate.',
      if (freshnessPriorityLabel.isNotEmpty) freshnessPriorityLabel,
      if (harvestPrepGap > 0)
        'Create harvest prep for $harvestPrepGap crop${harvestPrepGap == 1 ? '' : 's'} so stock and sales do not lag behind the field.',
      if (pendingCollectionsValue > 0 &&
          monthlySales > 0 &&
          pendingCollectionsValue > monthlySales * 0.4)
        'Collections are tying up too much cash. Follow up unpaid buyers before adding more spend.',
      if (projectedCashBuffer < 0)
        'Your current cash buffer is negative. Delay non-essential buying until sales or collections improve.',
      if (feedReadinessGaps > 0)
        'Restock feed early and keep the unit consistent with your ration schedules so deductions stay automatic.',
      if (cropInputGaps > 0)
        'Source missing crop inputs before the next field operation so planting or spraying does not slip.',
      if (overdueTasks >= 4)
        'Too much work is slipping overdue. Reduce the number of open tasks or reassign work before operations become reactive.',
      if (approvalPendingTasks >= 3)
        'Approvals are starting to slow execution. Managers should clear the approval queue earlier in the day.',
      if (milkTrendBand == 'Down')
        'Milk output is down against the previous 7-day run. Check feed consistency, health notes, and missed milking logs.',
      if (eggsTrendBand == 'Down')
        'Egg production is softening against the last 7 days. Review layer feed quality, water access, and flock health.',
      if (feedCostsMonth > 0 &&
          dairyRevenueMonth > 0 &&
          feedCostsMonth > dairyRevenueMonth * 0.6)
        'Feed costs are taking too much of dairy income. Tighten ration logging and review waste before buying more.',
      if (collectionsRatio >= 0.4)
        'Too much monthly revenue is still unpaid. Tighten buyer follow-up and avoid extending more credit until cash catches up.',
      if (breedingReviewsDue > 0)
        'Keep upcoming births visible now so housing, treatment, and feed planning are ready before they become urgent.',
      if (cropStageReviewsDue > 0)
        'Several crop blocks are deep into the season. Run a field timing review so irrigation, spraying, and harvest prep stay aligned.',
      if (treatmentFollowUps > 0)
        'Recent treatments still need response checks. Close the loop so health records stay useful for the next decision.',
    ];
    final healthReviewRows = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM animal_health_records
      WHERE treated_at IS NOT NULL
        AND DATE(treated_at) >= DATE(?)
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null
          ? [nextDateIso(-7)]
          : [nextDateIso(-7), activeUserId],
    );
    final healthRecordsLast7Days =
        Sqflite.firstIntValue(healthReviewRows) ?? 0;
    final verificationScore = _computeVerificationScore(
      cropCount: cropCount,
      animalCount: animalCount,
      inventoryCount: inventoryCount,
      pendingTasksCount: pendingTasksCount,
      todaysFeedings: todaysFeedings,
      lowStockItems: lowStockItems,
      monthlySales: monthlySales,
      monthlyExpenses: monthlyExpenses,
      pendingCollectionsValue: pendingCollectionsValue,
      productionValueToday: productionValueToday,
    );
    final marketplaceTrustScore = _computeMarketplaceTrustScore(
      verificationScore: verificationScore,
      pendingCollectionsValue: pendingCollectionsValue,
      monthlySales: monthlySales,
      lowStockItems: lowStockItems,
      oldestFreshOutputAgeHours: oldestFreshOutputAgeHours,
    );
    final lendingReadinessScore = _computeLendingReadinessScore(
      verificationScore: verificationScore,
      marketplaceTrustScore: marketplaceTrustScore,
      projectedCashBuffer: projectedCashBuffer,
      monthlyNetCashFlow: monthlyNetCashFlow,
      pendingCollectionsValue: pendingCollectionsValue,
    );
    final operationsHealthScore = _computeOperationsHealthScore(
      overdueTasks: overdueTasks,
      dueTodayTasks: dueTodayTasks,
      missedFeedingsToday: missedFeedingsToday,
      lowStockItems: lowStockItems,
      feedReadinessGaps: feedReadinessGaps,
      cropInputGaps: cropInputGaps,
      approvalPendingTasks: approvalPendingTasks,
      harvestPrepGap: harvestPrepGap,
      healthRecordsLast7Days: healthRecordsLast7Days,
    );
    final executionPressure = overdueTasks +
        missedFeedingsToday +
        approvalPendingTasks +
        harvestPrepGap;
    final executionPressureBand = executionPressure >= 8
        ? 'High'
        : executionPressure >= 4
            ? 'Moderate'
            : 'Stable';

    return {
      "crops": cropCount,
      "livestock": animalCount,
      "inventory": inventoryCount,
      "pendingTasks": pendingTasksCount,
      "salesToday": salesToday,
      "monthlySales": monthlySales,
      "expensesToday": expensesToday,
      "monthlyExpenses": monthlyExpenses,
      "trailing7DaySales": trailing7DaySales,
      "trailing7DayExpenses": trailing7DayExpenses,
      "netCashFlowToday": salesToday - expensesToday,
      "monthlyNetCashFlow": monthlyNetCashFlow,
      "lowStockItems": lowStockItems,
      "milkToday": milkToday,
      "eggsToday": eggsToday,
      "milkSoldToday": milkSoldToday,
      "eggsSoldToday": eggsSoldToday,
      "milkStockOnHand": milkStockOnHand,
      "eggsStockOnHand": eggsStockOnHand,
      "unsoldMilkToday": unsoldMilkToday,
      "unsoldEggsToday": unsoldEggsToday,
      "outputStockValue": outputStockValue,
      "oldestFreshOutputAgeHours": oldestFreshOutputAgeHours,
      "freshnessRiskCount": freshnessRiskCount,
      "freshnessPriorityLabel": freshnessPriorityLabel,
      "productionValueToday": productionValueToday,
      "todaysFeedings": todaysFeedings,
      "feedingLogsToday": feedingLogsToday,
      "missedFeedingsToday": missedFeedingsToday,
      "todaysFeedingPreview": todaysFeedingPreview,
      "overdueTasks": overdueTasks,
      "dueTodayTasks": dueTodayTasks,
      "dueThisWeekTasks": dueThisWeekTasks,
      "approvalPendingTasks": approvalPendingTasks,
      "setupTasksNext7Days": setupTasksNext7Days,
      "setupTasksNext30Days": setupTasksNext30Days,
      "activeFieldCrops": activeFieldCrops,
      "productionReviewsNext7Days": productionReviewsNext7Days,
      "harvestReadyCrops": harvestReadyCrops,
      "harvestPrepGap": harvestPrepGap,
      "healthRecordsLast7Days": healthRecordsLast7Days,
      "breedingReviewsDue": breedingReviewsDue,
      "treatmentFollowUps": treatmentFollowUps,
      "cropStageReviewsDue": cropStageReviewsDue,
      "feedReadinessGaps": feedReadinessGaps,
      "cropInputGaps": cropInputGaps,
      "pendingCollectionsCount": pendingCollectionsCount,
      "pendingCollectionsValue": pendingCollectionsValue,
      "collectionsRatio": collectionsRatio,
      "restockCostEstimate": restockCostEstimate,
      "projectedCashBuffer": projectedCashBuffer,
      "dairyRevenueMonth": dairyRevenueMonth,
      "poultryRevenueMonth": poultryRevenueMonth,
      "livestockRevenueMonth": livestockRevenueMonth,
      "otherRevenueMonth": otherRevenueMonth,
      "feedCostsMonth": feedCostsMonth,
      "vetCostsMonth": vetCostsMonth,
      "cropCostsMonth": cropCostsMonth,
      "laborCostsMonth": laborCostsMonth,
      "enterpriseFocus": enterpriseFocus,
      "milkCurrent7Days": milkCurrent7Days,
      "milkPrevious7Days": milkPrevious7Days,
      "eggsCurrent7Days": eggsCurrent7Days,
      "eggsPrevious7Days": eggsPrevious7Days,
      "milkTrendBand": milkTrendBand,
      "eggsTrendBand": eggsTrendBand,
      "costDisciplineBand": costDisciplineBand,
      "collectionsDisciplineBand": collectionsDisciplineBand,
      "todayAgendaCount": todayAgendaItems.length,
      "todayAgendaPreview": todayAgendaItems.take(3).join(' • '),
      "todayAgendaPrimary": todayAgendaItems.isEmpty
          ? 'No urgent actions lined up'
          : todayAgendaItems.first,
      "thisWeekFocusCount": thisWeekFocusItems.length,
      "thisWeekFocusPreview": thisWeekFocusItems.take(3).join(' • '),
      "adviceCount": adviceItems.length,
      "advicePrimary": adviceItems.isEmpty
          ? 'Keep logging farm work as it happens so Farmly can automate the rest reliably.'
          : adviceItems.first,
      "adviceSecondary": adviceItems.length > 1 ? adviceItems[1] : '',
      "adviceTertiary": adviceItems.length > 2 ? adviceItems[2] : '',
      "enterpriseAdvicePrimary": _enterpriseAdvicePrimary(
        enterpriseFocus: enterpriseFocus,
        milkTrendBand: milkTrendBand,
        eggsTrendBand: eggsTrendBand,
        costDisciplineBand: costDisciplineBand,
        collectionsDisciplineBand: collectionsDisciplineBand,
      ),
      "enterpriseAdviceSecondary": _enterpriseAdviceSecondary(
        breedingReviewsDue: breedingReviewsDue,
        treatmentFollowUps: treatmentFollowUps,
        cropStageReviewsDue: cropStageReviewsDue,
      ),
      "operationsHealthScore": operationsHealthScore,
      "operationsHealthBand": _scoreBand(operationsHealthScore),
      "executionPressureBand": executionPressureBand,
      "smartReminderCount": reminderSignals.length,
      "smartReminderPreview": smartReminderPreview,
      "verificationScore": verificationScore,
      "verificationBand": _scoreBand(verificationScore),
      "marketplaceTrustScore": marketplaceTrustScore,
      "marketplaceTrustBand": _scoreBand(marketplaceTrustScore),
      "lendingReadinessScore": lendingReadinessScore,
      "lendingReadinessBand": _scoreBand(lendingReadinessScore),
    };
  }

  static String nextDateIso(int days) {
    return DateTime.now()
        .add(Duration(days: days))
        .toIso8601String()
        .split('T')
        .first;
  }

  static String _extractRationLabel(String? notes) {
    if (notes == null || notes.trim().isEmpty) return '';
    for (final line in notes.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.toLowerCase().startsWith(_rationLabelPrefix)) {
        return trimmed.substring(_rationLabelPrefix.length).trim();
      }
    }
    return '';
  }

  static bool _isMilkInventoryRow(Map<String, Object?> row) {
    final itemName = (row['item_name'] ?? '').toString().trim().toLowerCase();
    final category = (row['category'] ?? '').toString().trim().toLowerCase();
    return itemName == 'milk' ||
        (category == 'dairy' && itemName.contains('milk'));
  }

  static bool _isEggInventoryRow(Map<String, Object?> row) {
    final itemName = (row['item_name'] ?? '').toString().trim().toLowerCase();
    final category = (row['category'] ?? '').toString().trim().toLowerCase();
    return itemName == 'egg' ||
        itemName == 'eggs' ||
        (category == 'poultry' && itemName.contains('egg'));
  }

  static double _ageInHours(DateTime? from, DateTime to) {
    if (from == null) return 0;
    return to.difference(from).inMinutes / 60.0;
  }

  static String _formatStockQuantity(double quantity, String unit) {
    final quantityText = quantity == quantity.roundToDouble()
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(1);
    return '$quantityText $unit';
  }

  static int _computeVerificationScore({
    required int cropCount,
    required int animalCount,
    required int inventoryCount,
    required int pendingTasksCount,
    required int todaysFeedings,
    required int lowStockItems,
    required double monthlySales,
    required double monthlyExpenses,
    required double pendingCollectionsValue,
    required double productionValueToday,
  }) {
    var score = 20;
    if (cropCount > 0 || animalCount > 0) score += 18;
    if (inventoryCount > 0) score += 12;
    if (monthlySales > 0) score += 15;
    if (monthlyExpenses > 0) score += 10;
    if (productionValueToday > 0) score += 10;
    if (todaysFeedings > 0) score += 8;
    if (pendingTasksCount <= 3) {
      score += 7;
    } else if (pendingTasksCount <= 7) {
      score += 3;
    }
    if (lowStockItems == 0) score += 8;
    if (pendingCollectionsValue <= monthlySales * 0.35) {
      score += 12;
    } else if (pendingCollectionsValue <= monthlySales * 0.65) {
      score += 6;
    }
    return score.clamp(0, 100);
  }

  static int _computeMarketplaceTrustScore({
    required int verificationScore,
    required double pendingCollectionsValue,
    required double monthlySales,
    required int lowStockItems,
    required double oldestFreshOutputAgeHours,
  }) {
    var score = (verificationScore * 0.55).round();
    if (monthlySales > 0 && pendingCollectionsValue <= monthlySales * 0.25) {
      score += 20;
    } else if (monthlySales > 0 &&
        pendingCollectionsValue <= monthlySales * 0.5) {
      score += 10;
    }
    if (lowStockItems <= 2) score += 10;
    if (oldestFreshOutputAgeHours <= 24) score += 15;
    return score.clamp(0, 100);
  }

  static int _computeLendingReadinessScore({
    required int verificationScore,
    required int marketplaceTrustScore,
    required double projectedCashBuffer,
    required double monthlyNetCashFlow,
    required double pendingCollectionsValue,
  }) {
    var score =
        ((verificationScore * 0.45) + (marketplaceTrustScore * 0.25)).round();
    if (monthlyNetCashFlow >= 0) score += 15;
    if (projectedCashBuffer >= 0) score += 10;
    if (pendingCollectionsValue <= (monthlyNetCashFlow.abs() + 1) * 1.5) {
      score += 5;
    }
    return score.clamp(0, 100);
  }

  static int _computeOperationsHealthScore({
    required int overdueTasks,
    required int dueTodayTasks,
    required int missedFeedingsToday,
    required int lowStockItems,
    required int feedReadinessGaps,
    required int cropInputGaps,
    required int approvalPendingTasks,
    required int harvestPrepGap,
    required int healthRecordsLast7Days,
  }) {
    var score = 88;
    score -= overdueTasks * 7;
    score -= dueTodayTasks * 2;
    score -= missedFeedingsToday * 10;
    score -= lowStockItems * 3;
    score -= feedReadinessGaps * 6;
    score -= cropInputGaps * 5;
    score -= approvalPendingTasks * 4;
    score -= harvestPrepGap * 6;
    if (healthRecordsLast7Days == 0) {
      score -= 8;
    } else if (healthRecordsLast7Days >= 3) {
      score += 4;
    }
    return score.clamp(0, 100);
  }

  static double _sumMapValues(
    Map<String, double> source,
    Set<String> keys,
  ) {
    var total = 0.0;
    for (final entry in source.entries) {
      if (keys.contains(entry.key.toLowerCase())) {
        total += entry.value;
      }
    }
    return total;
  }

  static String _trendBand(double current, double previous) {
    if (current <= 0 && previous <= 0) return 'No data';
    if (previous <= 0) return current > 0 ? 'Up' : 'Stable';
    final ratio = (current - previous) / previous;
    if (ratio >= 0.12) return 'Up';
    if (ratio <= -0.12) return 'Down';
    return 'Stable';
  }

  static String _costDisciplineBand({
    required double monthlySales,
    required double monthlyExpenses,
    required double feedCostsMonth,
    required double cropCostsMonth,
  }) {
    if (monthlySales <= 0 && monthlyExpenses <= 0) return 'Building';
    final expenseRatio = monthlySales <= 0 ? 1.0 : monthlyExpenses / monthlySales;
    if (expenseRatio <= 0.45 &&
        feedCostsMonth + cropCostsMonth <= monthlySales * 0.55) {
      return 'Strong';
    }
    if (expenseRatio <= 0.8) return 'Watch';
    return 'Tight';
  }

  static String _collectionsDisciplineBand(double collectionsRatio) {
    if (collectionsRatio <= 0.2) return 'Strong';
    if (collectionsRatio <= 0.4) return 'Watch';
    return 'Tight';
  }

  static String _enterpriseFocus({
    required double dairyRevenueMonth,
    required double poultryRevenueMonth,
    required double livestockRevenueMonth,
    required double otherRevenueMonth,
    required double milkCurrent7Days,
    required double eggsCurrent7Days,
    required int activeFieldCrops,
  }) {
    final candidates = <String, double>{
      'Dairy': dairyRevenueMonth + milkCurrent7Days,
      'Poultry': poultryRevenueMonth + eggsCurrent7Days,
      'Livestock': livestockRevenueMonth,
      'Crops': activeFieldCrops.toDouble() * 10,
      'Other': otherRevenueMonth,
    };
    final sorted = candidates.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.value <= 0 ? 'Mixed farm' : sorted.first.key;
  }

  static String _enterpriseAdvicePrimary({
    required String enterpriseFocus,
    required String milkTrendBand,
    required String eggsTrendBand,
    required String costDisciplineBand,
    required String collectionsDisciplineBand,
  }) {
    if (enterpriseFocus == 'Dairy' && milkTrendBand == 'Down') {
      return 'Dairy is leading the farm, and milk trend is down. Review feed consistency, health, and missed milking logs first.';
    }
    if (enterpriseFocus == 'Poultry' && eggsTrendBand == 'Down') {
      return 'Poultry is carrying the farm, but egg output is softening. Check layer feed, water access, and flock health early.';
    }
    if (costDisciplineBand == 'Tight') {
      return 'Operating costs are tighter than they should be. Review feed, crop inputs, and labor before adding more spend.';
    }
    if (collectionsDisciplineBand == 'Tight') {
      return 'Collections are lagging. Push buyer follow-up before relying on more credit-funded operations.';
    }
    return 'Keep your strongest enterprise well logged. Good records there improve the advice Farmly can give across the farm.';
  }

  static String _enterpriseAdviceSecondary({
    required int breedingReviewsDue,
    required int treatmentFollowUps,
    required int cropStageReviewsDue,
  }) {
    if (breedingReviewsDue > 0) {
      return '$breedingReviewsDue breeding follow-up${breedingReviewsDue == 1 ? '' : 's'} need preparation before due dates tighten.';
    }
    if (treatmentFollowUps > 0) {
      return '$treatmentFollowUps recent treatment follow-up${treatmentFollowUps == 1 ? '' : 's'} still need outcome checks.';
    }
    if (cropStageReviewsDue > 0) {
      return '$cropStageReviewsDue active crop block${cropStageReviewsDue == 1 ? '' : 's'} need irrigation or spray timing review.';
    }
    return 'Use weekly reviews to keep field timing, animal care, and finance decisions moving together.';
  }

  static String _scoreBand(int score) {
    if (score >= 80) return 'Strong';
    if (score >= 60) return 'Building';
    if (score >= 40) return 'Emerging';
    return 'Needs work';
  }

  static Future<List<OperationalInsight>> getOperationalInsights({
    int limit = 5,
  }) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayIso = today.toIso8601String().split('T').first;
    final nextWeekIso =
        today.add(const Duration(days: 7)).toIso8601String().split('T').first;

    final overdueTasksResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM tasks
      WHERE status != ?
        AND due_date IS NOT NULL
        AND DATE(due_date) < DATE(?)
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null
          ? ['completed', todayIso]
          : ['completed', todayIso, activeUserId],
    );
    final overdueTasks = Sqflite.firstIntValue(overdueTasksResult) ?? 0;

    final dueTodayTasksResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM tasks
      WHERE status != ?
        AND due_date IS NOT NULL
        AND DATE(due_date) = DATE(?)
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null
          ? ['completed', todayIso]
          : ['completed', todayIso, activeUserId],
    );
    final dueTodayTasks = Sqflite.firstIntValue(dueTodayTasksResult) ?? 0;

    final lowStockResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM inventory
      WHERE min_stock > 0 AND quantity <= min_stock
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null ? null : [activeUserId],
    );
    final lowStockCount = Sqflite.firstIntValue(lowStockResult) ?? 0;

    final harvestSoonResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM crops
      WHERE expected_harvest_date IS NOT NULL
        AND LOWER(COALESCE(status, '')) != 'harvested'
        AND DATE(expected_harvest_date) <= DATE(?)
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null ? [nextWeekIso] : [nextWeekIso, activeUserId],
    );
    final harvestSoonCount = Sqflite.firstIntValue(harvestSoonResult) ?? 0;

    final unpaidSalesResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM sales
      WHERE LOWER(COALESCE(payment_status, 'pending')) != 'paid'
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null ? null : [activeUserId],
    );
    final unpaidSalesCount = Sqflite.firstIntValue(unpaidSalesResult) ?? 0;

    final activeFeedingSchedulesResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM feeding_schedules
      WHERE completed = 0
        AND (start_date IS NULL OR DATE(start_date) <= DATE(?))
        AND (end_date IS NULL OR DATE(end_date) >= DATE(?))
        ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null
          ? [todayIso, todayIso]
          : [todayIso, todayIso, activeUserId],
    );
    final activeFeedingSchedules =
        Sqflite.firstIntValue(activeFeedingSchedulesResult) ?? 0;

    final outputReadyRows = await db.rawQuery(
      '''
      SELECT
        SUM(
          CASE
            WHEN LOWER(COALESCE(item_name, '')) = 'milk'
              OR LOWER(COALESCE(item_name, '')) = 'eggs'
              OR (LOWER(COALESCE(category, '')) = 'dairy' AND LOWER(COALESCE(item_name, '')) LIKE '%milk%')
              OR (LOWER(COALESCE(category, '')) = 'poultry' AND LOWER(COALESCE(item_name, '')) LIKE '%egg%')
            THEN COALESCE(quantity, 0)
            ELSE 0
          END
        ) AS ready_quantity
      FROM inventory
      WHERE COALESCE(quantity, 0) > 0
      ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null ? null : [activeUserId],
    );
    final readyOutputQuantity =
        (outputReadyRows.first['ready_quantity'] as num?)?.toDouble() ?? 0.0;

    final agingOutputRows = await db.rawQuery(
      '''
      SELECT item_name, category, quantity, unit, last_restock, last_updated
      FROM inventory
      WHERE COALESCE(quantity, 0) > 0
      ${activeUserId == null ? '' : 'AND user_id = ?'}
      ''',
      activeUserId == null ? null : [activeUserId],
    );
    var freshnessRiskCount = 0;
    for (final row in agingOutputRows) {
      final normalized = Map<String, Object?>.from(row);
      if (!_isMilkInventoryRow(normalized) && !_isEggInventoryRow(normalized)) {
        continue;
      }
      final timestampValue =
          (normalized['last_restock'] ?? normalized['last_updated'])
              ?.toString();
      final timestamp = timestampValue == null
          ? null
          : DateTime.tryParse(timestampValue)?.toLocal();
      final ageHours = _ageInHours(timestamp, now);
      if ((_isMilkInventoryRow(normalized) && ageHours >= 18) ||
          (_isEggInventoryRow(normalized) && ageHours >= 72)) {
        freshnessRiskCount++;
      }
    }

    final insights = <OperationalInsight>[
      if (freshnessRiskCount > 0)
        OperationalInsight(
          id: 'freshness_risk',
          title:
              '$freshnessRiskCount fresh-output lot${freshnessRiskCount == 1 ? '' : 's'} need selling now',
          description:
              'Milk and eggs already in stock are aging. Move the oldest output first so trust, quality, and pricing stay strong.',
          severity: OperationalInsightSeverity.critical,
          action: OperationalInsightAction.business,
          actionLabel: 'Move output',
        ),
      if (overdueTasks > 0)
        OperationalInsight(
          id: 'overdue_tasks',
          title: '$overdueTasks overdue task${overdueTasks == 1 ? '' : 's'}',
          description:
              'Clear delayed farm work first so records, feeding, and harvest operations stay accurate.',
          severity: OperationalInsightSeverity.critical,
          action: OperationalInsightAction.tasks,
          actionLabel: 'Review tasks',
        ),
      if (lowStockCount > 0)
        OperationalInsight(
          id: 'low_stock',
          title:
              '$lowStockCount low-stock item${lowStockCount == 1 ? '' : 's'}',
          description:
              'Restocking early prevents missed feeding, treatment, and field operations.',
          severity: OperationalInsightSeverity.critical,
          action: OperationalInsightAction.inventory,
          actionLabel: 'Open inventory',
        ),
      if (harvestSoonCount > 0)
        OperationalInsight(
          id: 'harvest_window',
          title:
              '$harvestSoonCount crop${harvestSoonCount == 1 ? '' : 's'} nearing harvest',
          description:
              'Prepare labor, buyers, and storage before the harvest window closes.',
          severity: OperationalInsightSeverity.warning,
          action: OperationalInsightAction.farm,
          actionLabel: 'Check farm',
        ),
      if (unpaidSalesCount > 0)
        OperationalInsight(
          id: 'pending_collections',
          title:
              '$unpaidSalesCount sale${unpaidSalesCount == 1 ? '' : 's'} awaiting payment',
          description:
              'Track collections consistently so finance data can support pricing, inventory, and future lending.',
          severity: OperationalInsightSeverity.warning,
          action: OperationalInsightAction.business,
          actionLabel: 'Open business',
        ),
      if (readyOutputQuantity > 0)
        OperationalInsight(
          id: 'output_ready',
          title: readyOutputQuantity == readyOutputQuantity.roundToDouble()
              ? '${readyOutputQuantity.toInt()} output unit${readyOutputQuantity == 1 ? '' : 's'} ready in stock'
              : '${readyOutputQuantity.toStringAsFixed(1)} output units ready in stock',
          description:
              'Move stocked milk or eggs into sales while they are still fresh and visible to buyers.',
          severity: OperationalInsightSeverity.warning,
          action: OperationalInsightAction.business,
          actionLabel: 'Review output',
        ),
      if (dueTodayTasks > 0 && overdueTasks == 0)
        OperationalInsight(
          id: 'due_today',
          title:
              '$dueTodayTasks task${dueTodayTasks == 1 ? '' : 's'} due today',
          description:
              'Completing scheduled work on time improves automation accuracy across the app.',
          severity: OperationalInsightSeverity.info,
          action: OperationalInsightAction.tasks,
          actionLabel: 'View schedule',
        ),
      if (activeFeedingSchedules > 0)
        OperationalInsight(
          id: 'active_feeding',
          title:
              '$activeFeedingSchedules active feeding plan${activeFeedingSchedules == 1 ? '' : 's'}',
          description:
              'Use feeding plans as the operational baseline so stock usage and animal records stay linked.',
          severity: OperationalInsightSeverity.info,
          action: OperationalInsightAction.farm,
          actionLabel: 'Open animals',
        ),
    ];

    if (insights.isEmpty) {
      insights.add(
        const OperationalInsight(
          id: 'stable',
          title: 'No urgent farm blockers',
          description:
              'The next step is improving automation quality with more connected sales, feeding, and cost records.',
          severity: OperationalInsightSeverity.info,
          action: OperationalInsightAction.farm,
          actionLabel: 'Review farm',
        ),
      );
    }

    return insights.take(limit).toList();
  }

  static Future<List<Map<String, dynamic>>> getUpcomingTasks({
    int limit = 5,
  }) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    return db.query(
      'tasks',
      columns: ['id', 'title', 'due_date', 'status', 'priority'],
      where:
          activeUserId == null ? 'status != ?' : 'status != ? AND user_id = ?',
      whereArgs:
          activeUserId == null ? ['completed'] : ['completed', activeUserId],
      orderBy: 'CASE WHEN due_date IS NULL THEN 1 ELSE 0 END, due_date ASC',
      limit: limit,
    );
  }

  static Future<List<Map<String, dynamic>>> getRecentSales({
    int limit = 5,
  }) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    return db.query(
      'sales',
      columns: [
        'id',
        'product_name',
        'total_amount',
        'sale_date',
        'payment_status',
        'customer_name',
      ],
      where: activeUserId == null ? null : 'user_id = ?',
      whereArgs: activeUserId == null ? null : [activeUserId],
      orderBy: 'sale_date DESC',
      limit: limit,
    );
  }

  static Future<List<Map<String, dynamic>>> getRecentExpenses({
    int limit = 5,
  }) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    return db.query(
      'expenses',
      columns: [
        'id',
        'category',
        'item_name',
        'amount',
        'expense_date',
        'vendor_name',
        'payment_method',
      ],
      where: activeUserId == null ? null : 'user_id = ?',
      whereArgs: activeUserId == null ? null : [activeUserId],
      orderBy: 'expense_date DESC',
      limit: limit,
    );
  }

  static Future<int> insertExpense(Map<String, dynamic> expense) async {
    final db = await _dbHelper.database;
    return db.insert('expenses', await _attachActiveUserId(expense));
  }

  static Future<List<Map<String, dynamic>>> getProductionTrend({
    int days = 7,
  }) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    final startDate = DateTime.now().subtract(Duration(days: days - 1));
    final start = DateTime(startDate.year, startDate.month, startDate.day)
        .toIso8601String();

    final rows = await db.rawQuery('''
      SELECT DATE(date_produced) as day, COALESCE(SUM(quantity), 0) as total
      FROM production_logs
      WHERE date_produced >= ?
      ${activeUserId == null ? '' : 'AND user_id = ?'}
      GROUP BY DATE(date_produced)
      ORDER BY day ASC
    ''', activeUserId == null ? [start] : [start, activeUserId]);

    final totalsByDay = <String, double>{
      for (final row in rows)
        (row['day']?.toString() ?? ''):
            (row['total'] as num?)?.toDouble() ?? 0.0,
    };

    final trend = <Map<String, dynamic>>[];
    for (var i = days - 1; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      trend.add({
        'day': key,
        'total': totalsByDay[key] ?? 0.0,
      });
    }
    return trend;
  }

  static Future<List<Map<String, String>>> getMarketPrices() async {
    // For now, return cached or default data
    // In future, this will fetch from API and cache
    return [
      {"item": "Maize", "price": "Ksh 4,200 / 90kg bag"},
      {"item": "Beans", "price": "Ksh 6,000 / 90kg bag"},
      {"item": "Tomatoes", "price": "Ksh 2,800 / 90kg bag"},
      {"item": "Cabbages", "price": "Ksh 1,200 / 90kg bag"}
    ];
  }

  // Animal CRUD operations
  static Future<List<Animal>> getAnimals() async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    final List<Map<String, dynamic>> maps = await db.query(
      'animals',
      where: activeUserId == null ? null : 'user_id = ?',
      whereArgs: activeUserId == null ? null : [activeUserId],
    );
    return List.generate(maps.length, (i) => Animal.fromMap(maps[i]));
  }

  static Future<int> insertAnimal(Animal animal) async {
    final db = await _dbHelper.database;
    return await db.insert(
        'animals', await _attachActiveUserId(animal.toMap()));
  }

  static Future<int> upsertAnimal(Animal animal) async {
    final db = await _dbHelper.database;
    final map = await _attachActiveUserId(animal.toMap());
    if (animal.id == null) {
      return await db.insert('animals', map);
    }
    return await db.insert(
      'animals',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateAnimal(Animal animal) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    final row = await _attachActiveUserId(animal.toMap());
    return await db.update(
      'animals',
      row,
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [animal.id] : [animal.id, activeUserId],
    );
  }

  static Future<int> deleteAnimal(int id) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    return await db.delete(
      'animals',
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [id] : [id, activeUserId],
    );
  }

  // Crop CRUD operations
  static Future<List<Crop>> getCrops() async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    final List<Map<String, dynamic>> maps = await db.query(
      'crops',
      where: activeUserId == null ? null : 'user_id = ?',
      whereArgs: activeUserId == null ? null : [activeUserId],
    );
    return List.generate(maps.length, (i) => Crop.fromMap(maps[i]));
  }

  static Future<int> insertCrop(Crop crop) async {
    final db = await _dbHelper.database;
    return await db.insert('crops', await _attachActiveUserId(crop.toMap()));
  }

  static Future<int> upsertCrop(Crop crop) async {
    final db = await _dbHelper.database;
    final map = await _attachActiveUserId({
      'id': crop.id,
      ...crop.toMap(),
    });
    if (crop.id == null) {
      map.remove('id');
      return await db.insert('crops', map);
    }
    return await db.insert(
      'crops',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateCrop(Crop crop) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    final row = await _attachActiveUserId(crop.toMap());
    return await db.update(
      'crops',
      row,
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [crop.id] : [crop.id, activeUserId],
    );
  }

  static Future<int> deleteCrop(int id) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    return await db.delete(
      'crops',
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [id] : [id, activeUserId],
    );
  }

  // Task CRUD operations
  static Future<List<Task>> getTasks() async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: activeUserId == null ? null : 'user_id = ?',
      whereArgs: activeUserId == null ? null : [activeUserId],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  static Future<int> insertTask(Task task) async {
    final db = await _dbHelper.database;
    final map = await _attachActiveUserId(
      task.toMap()
        ..['is_synced'] = task.isSynced == null ? 0 : (task.isSynced! ? 1 : 0),
    );
    return await db.insert('tasks', map);
  }

  static Future<int> upsertTask(Task task) async {
    final db = await _dbHelper.database;
    final map = await _attachActiveUserId(
      task.toMap()
        ..['is_synced'] = task.isSynced == null ? 1 : (task.isSynced! ? 1 : 0),
    );
    if (task.id == null) {
      return await db.insert('tasks', map);
    }
    return await db.insert(
      'tasks',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateTask(Task task) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    final existing = await db.query(
      'tasks',
      columns: ['is_synced'],
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [task.id] : [task.id, activeUserId],
      limit: 1,
    );
    final isSynced =
        existing.isNotEmpty ? (existing.first['is_synced'] ?? 0) : 0;
    final nextSynced =
        task.isSynced == null ? isSynced : (task.isSynced! ? 1 : 0);
    final row = await _attachActiveUserId(
      task.toMap()..['is_synced'] = nextSynced,
    );
    return await db.update(
      'tasks',
      row,
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [task.id] : [task.id, activeUserId],
    );
  }

  static Future<int?> findTaskIdByClientUuid(String clientUuid) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    final rows = await db.query(
      'tasks',
      columns: ['id'],
      where: activeUserId == null
          ? 'client_uuid = ?'
          : 'client_uuid = ? AND user_id = ?',
      whereArgs:
          activeUserId == null ? [clientUuid] : [clientUuid, activeUserId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final id = rows.first['id'];
    if (id is int) return id;
    return int.tryParse('$id');
  }

  static Future<int> deleteTask(int id) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    return await db.delete(
      'tasks',
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [id] : [id, activeUserId],
    );
  }

  static Future<bool> isTaskSynced(int id) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    final rows = await db.query(
      'tasks',
      columns: ['is_synced'],
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [id] : [id, activeUserId],
      limit: 1,
    );
    if (rows.isEmpty) return false;
    return (rows.first['is_synced'] ?? 0) == 1;
  }

  static Future<bool> isTaskUnsynced(int id) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    final rows = await db.query(
      'tasks',
      columns: ['is_synced'],
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [id] : [id, activeUserId],
      limit: 1,
    );
    if (rows.isEmpty) return false;
    return (rows.first['is_synced'] ?? 0) != 1;
  }

  static Future<void> queueTaskDelete(int taskServerId) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    await db.insert(
      'task_delete_sync_queue',
      {
        'task_server_id': taskServerId,
        'created_at': DateTime.now().toIso8601String(),
        'retry_count': 0,
        'user_id': activeUserId,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<List<Map<String, dynamic>>> getPendingTaskDeletes() async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    return db.query(
      'task_delete_sync_queue',
      where: activeUserId == null ? null : 'user_id = ?',
      whereArgs: activeUserId == null ? null : [activeUserId],
      orderBy: 'created_at ASC',
    );
  }

  static Future<int> deletePendingTaskDelete(int id) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    return db.delete(
      'task_delete_sync_queue',
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [id] : [id, activeUserId],
    );
  }

  static Future<int> deletePendingTaskDeleteByServerId(int taskServerId) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    return db.delete(
      'task_delete_sync_queue',
      where: activeUserId == null
          ? 'task_server_id = ?'
          : 'task_server_id = ? AND user_id = ?',
      whereArgs:
          activeUserId == null ? [taskServerId] : [taskServerId, activeUserId],
    );
  }

  static Future<int> updatePendingTaskDeleteRetryCount(
      int id, int retryCount) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    return db.update(
      'task_delete_sync_queue',
      {'retry_count': retryCount},
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [id] : [id, activeUserId],
    );
  }

  static Future<Set<int>> getPendingTaskDeleteServerIds() async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    final rows = await db.query(
      'task_delete_sync_queue',
      columns: ['task_server_id'],
      where: activeUserId == null ? null : 'user_id = ?',
      whereArgs: activeUserId == null ? null : [activeUserId],
    );
    return rows.map((row) => row['task_server_id']).whereType<int>().toSet();
  }

  static Future<void> queueTaskAction({
    required int localId,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    final encodedPayload = jsonEncode(payload);
    final existing = await db.query(
      'task_sync_queue',
      where: activeUserId == null
          ? 'task_local_id = ?'
          : 'task_local_id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [localId] : [localId, activeUserId],
      orderBy: 'created_at DESC',
    );

    if (action == 'update') {
      final createEntry = existing.firstWhere(
        (row) => row['action'] == 'create',
        orElse: () => const <String, dynamic>{},
      );
      if (createEntry.isNotEmpty) {
        await db.update(
          'task_sync_queue',
          {
            'payload': encodedPayload,
            'created_at': DateTime.now().toIso8601String(),
            'retry_count': 0,
          },
          where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
          whereArgs: activeUserId == null
              ? [createEntry['id']]
              : [createEntry['id'], activeUserId],
        );
        return;
      }

      final latestUpdate = existing.firstWhere(
        (row) => row['action'] == 'update',
        orElse: () => const <String, dynamic>{},
      );
      if (latestUpdate.isNotEmpty) {
        await db.update(
          'task_sync_queue',
          {
            'payload': encodedPayload,
            'created_at': DateTime.now().toIso8601String(),
            'retry_count': 0,
          },
          where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
          whereArgs: activeUserId == null
              ? [latestUpdate['id']]
              : [latestUpdate['id'], activeUserId],
        );
        return;
      }
    }

    if (action == 'create') {
      final latestCreate = existing.firstWhere(
        (row) => row['action'] == 'create',
        orElse: () => const <String, dynamic>{},
      );
      if (latestCreate.isNotEmpty) {
        await db.update(
          'task_sync_queue',
          {
            'payload': encodedPayload,
            'created_at': DateTime.now().toIso8601String(),
            'retry_count': 0,
          },
          where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
          whereArgs: activeUserId == null
              ? [latestCreate['id']]
              : [latestCreate['id'], activeUserId],
        );
        return;
      }
    }

    await db.insert('task_sync_queue', {
      'task_local_id': localId,
      'action': action,
      'payload': encodedPayload,
      'created_at': DateTime.now().toIso8601String(),
      'retry_count': 0,
      'user_id': activeUserId,
    });
  }

  static Future<List<Map<String, dynamic>>> getPendingTaskActions() async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    return db.query(
      'task_sync_queue',
      where: activeUserId == null ? null : 'user_id = ?',
      whereArgs: activeUserId == null ? null : [activeUserId],
      orderBy: 'created_at ASC',
    );
  }

  static Future<int> deletePendingTaskAction(int id) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    return db.delete(
      'task_sync_queue',
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [id] : [id, activeUserId],
    );
  }

  static Future<int> deletePendingTaskActionsForLocalId(int localId) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    return db.delete(
      'task_sync_queue',
      where: activeUserId == null
          ? 'task_local_id = ?'
          : 'task_local_id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [localId] : [localId, activeUserId],
    );
  }

  static Future<int> updatePendingTaskActionRetryCount(
      int id, int retryCount) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    return db.update(
      'task_sync_queue',
      {'retry_count': retryCount},
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [id] : [id, activeUserId],
    );
  }

  // Feeding Schedule CRUD operations
  static Future<List<FeedingSchedule>> getFeedingSchedules() async {
    final db = await _dbHelper.database;
    final activeUserId = await _localSessionService.getActiveUserId();
    final List<Map<String, dynamic>> maps = await db.query(
      'feeding_schedules',
      where: activeUserId == null ? null : 'user_id = ?',
      whereArgs: activeUserId == null ? null : [activeUserId],
    );
    return List.generate(maps.length, (i) => FeedingSchedule.fromMap(maps[i]));
  }

  static Future<int> insertFeedingSchedule(FeedingSchedule schedule) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'feeding_schedules',
      await _attachActiveUserId(schedule.toMap()),
    );
  }

  static Future<int> upsertFeedingSchedule(FeedingSchedule schedule) async {
    final db = await _dbHelper.database;
    final map = await _attachActiveUserId(schedule.toMap());
    if (schedule.id == null) {
      return await db.insert('feeding_schedules', map);
    }
    return await db.insert(
      'feeding_schedules',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateFeedingSchedule(FeedingSchedule schedule) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    final row = await _attachActiveUserId(schedule.toMap());
    return await db.update(
      'feeding_schedules',
      row,
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs:
          activeUserId == null ? [schedule.id] : [schedule.id, activeUserId],
    );
  }

  static Future<int> deleteFeedingSchedule(int id) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    return await db.delete(
      'feeding_schedules',
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [id] : [id, activeUserId],
    );
  }

  // Feeding Log CRUD operations
  static Future<List<FeedingLog>> getFeedingLogs() async {
    final db = await _dbHelper.database;
    final activeUserId = await _localSessionService.getActiveUserId();
    final List<Map<String, dynamic>> maps = await db.query(
      'feeding_logs',
      where: activeUserId == null ? null : 'user_id = ?',
      whereArgs: activeUserId == null ? null : [activeUserId],
    );
    return List.generate(maps.length, (i) => FeedingLog.fromMap(maps[i]));
  }

  static Future<int> insertFeedingLog(FeedingLog log) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'feeding_logs',
      await _attachActiveUserId(log.toMap()),
    );
  }

  static Future<int> upsertFeedingLog(FeedingLog log) async {
    final db = await _dbHelper.database;
    final map = await _attachActiveUserId(log.toMap());
    if (log.id == null) {
      return await db.insert('feeding_logs', map);
    }
    return await db.insert(
      'feeding_logs',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateFeedingLog(FeedingLog log) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    final row = await _attachActiveUserId(log.toMap());
    return await db.update(
      'feeding_logs',
      row,
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [log.id] : [log.id, activeUserId],
    );
  }

  static Future<int> deleteFeedingLog(int id) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    return await db.delete(
      'feeding_logs',
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [id] : [id, activeUserId],
    );
  }

  // Animal Health Record CRUD operations
  static Future<List<AnimalHealthRecord>> getAnimalHealthRecords() async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    final maps = await db.query(
      'animal_health_records',
      where: activeUserId == null ? null : 'user_id = ?',
      whereArgs: activeUserId == null ? null : [activeUserId],
      orderBy: 'treated_at DESC, id DESC',
    );
    return List.generate(
      maps.length,
      (i) => AnimalHealthRecord.fromMap(maps[i]),
    );
  }

  static Future<int> insertAnimalHealthRecord(AnimalHealthRecord record) async {
    final db = await _dbHelper.database;
    final map = await _attachActiveUserId(record.toMap());
    if (map['id'] == null) {
      map.remove('id');
    }
    return await db.insert('animal_health_records', map);
  }

  static Future<int> upsertAnimalHealthRecord(AnimalHealthRecord record) async {
    final db = await _dbHelper.database;
    final map = await _attachActiveUserId(record.toMap());
    if (record.id == null) {
      map.remove('id');
      return await db.insert('animal_health_records', map);
    }
    return await db.insert(
      'animal_health_records',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateAnimalHealthRecord(AnimalHealthRecord record) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    final row = await _attachActiveUserId(record.toMap());
    return await db.update(
      'animal_health_records',
      row,
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [record.id] : [record.id, activeUserId],
    );
  }

  static Future<int> deleteAnimalHealthRecord(int id) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    return await db.delete(
      'animal_health_records',
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [id] : [id, activeUserId],
    );
  }

  // Sales CRUD operations
  static Future<List<Map<String, dynamic>>> getSales() async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    final List<Map<String, dynamic>> maps = await db.query(
      'sales',
      where: activeUserId == null ? null : 'user_id = ?',
      whereArgs: activeUserId == null ? null : [activeUserId],
      orderBy: 'sale_date DESC',
    );
    return maps;
  }

  static Future<int> insertSale(Map<String, dynamic> sale) async {
    final db = await _dbHelper.database;

    // Ensure proper field mapping
    final row = await _attachActiveUserId(<String, dynamic>{
      'server_id': sale['server_id'] ?? sale['id'],
      'product_name': sale['product_name'],
      'type': sale['type'] ?? 'Other',
      'quantity': sale['quantity'],
      'unit': sale['unit'],
      'price': sale['price'],
      'total_amount': sale['total_amount'],
      'customer_name':
          sale['customer_name'] ?? sale['customer'], // Handle both formats
      'customer_id': sale['customer_id'],
      'sale_date': sale['sale_date'] ?? sale['date'], // Handle both formats
      'payment_status': sale['payment_status'] ?? 'Pending',
      'notes': sale['notes'] ?? '',
      'stock_deduction_plan': sale['stock_deduction_plan'] == null
          ? null
          : jsonEncode(sale['stock_deduction_plan']),
      'user_id': sale['user_id'],
    });

    // Validate required fields
    if ((row['product_name'] as String?)?.trim().isEmpty ?? true) {
      throw Exception('Invalid sale: product_name is required');
    }
    if ((row['customer_name'] as String?)?.trim().isEmpty ?? true) {
      throw Exception('Invalid sale: customer_name is required');
    }

    return await db.insert('sales', row);
  }

  static Future<int> upsertSaleFromServer(Map<String, dynamic> sale) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    final serverId = sale['id'];
    if (serverId == null) {
      return await insertSale(sale);
    }

    final row = await _attachActiveUserId(<String, dynamic>{
      'server_id': serverId,
      'product_name': sale['product_name'],
      'type': sale['type'] ?? 'Other',
      'quantity': sale['quantity'],
      'unit': sale['unit'],
      'price': sale['price'],
      'total_amount': sale['total_amount'],
      'customer_name': sale['customer_name'] ?? sale['customer'],
      'customer_id': sale['customer_id'],
      'sale_date': sale['sale_date'] ?? sale['date'],
      'payment_status': sale['payment_status'] ?? 'Pending',
      'notes': sale['notes'] ?? '',
      'stock_deduction_plan': sale['stock_deduction_plan'] == null
          ? null
          : jsonEncode(sale['stock_deduction_plan']),
      'user_id': sale['user_id'],
    });

    final existing = await db.query(
      'sales',
      columns: ['id'],
      where: activeUserId == null
          ? 'server_id = ?'
          : 'server_id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [serverId] : [serverId, activeUserId],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final localId = existing.first['id'] as int;
      await db.update('sales', row, where: 'id = ?', whereArgs: [localId]);
      return localId;
    }

    return await db.insert('sales', row);
  }

  static Future<int> updateSale(int id, Map<String, dynamic> sale) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();

    final row = await _attachActiveUserId(<String, dynamic>{
      'server_id': sale['server_id'] ?? sale['id'],
      'product_name': sale['product_name'],
      'type': sale['type'] ?? 'Other',
      'quantity': sale['quantity'],
      'unit': sale['unit'],
      'price': sale['price'],
      'total_amount': sale['total_amount'],
      'customer_name': sale['customer_name'] ?? sale['customer'],
      'customer_id': sale['customer_id'],
      'sale_date': sale['sale_date'] ?? sale['date'],
      'payment_status': sale['payment_status'] ?? 'Pending',
      'notes': sale['notes'] ?? '',
      'stock_deduction_plan': sale['stock_deduction_plan'] == null
          ? null
          : jsonEncode(sale['stock_deduction_plan']),
      'user_id': sale['user_id'],
    });

    return await db.update(
      'sales',
      row,
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [id] : [id, activeUserId],
    );
  }

  static Future<int> updateSaleByIdOrServerId(
      int id, Map<String, dynamic> sale) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();

    final row = await _attachActiveUserId(<String, dynamic>{
      'server_id': sale['server_id'] ?? sale['id'],
      'product_name': sale['product_name'],
      'type': sale['type'] ?? 'Other',
      'quantity': sale['quantity'],
      'unit': sale['unit'],
      'price': sale['price'],
      'total_amount': sale['total_amount'],
      'customer_name': sale['customer_name'] ?? sale['customer'],
      'customer_id': sale['customer_id'],
      'sale_date': sale['sale_date'] ?? sale['date'],
      'payment_status': sale['payment_status'] ?? 'Pending',
      'notes': sale['notes'] ?? '',
      'stock_deduction_plan': sale['stock_deduction_plan'] == null
          ? null
          : jsonEncode(sale['stock_deduction_plan']),
      'user_id': sale['user_id'],
    });

    return await db.update(
      'sales',
      row,
      where: activeUserId == null
          ? 'id = ? OR server_id = ?'
          : '(id = ? OR server_id = ?) AND user_id = ?',
      whereArgs: activeUserId == null ? [id, id] : [id, id, activeUserId],
    );
  }

  static Future<int> deleteSale(int id) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    return await db.delete(
      'sales',
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [id] : [id, activeUserId],
    );
  }

  static Future<int> deleteSaleByIdOrServerId(int id) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    return await db.delete(
      'sales',
      where: activeUserId == null
          ? 'id = ? OR server_id = ?'
          : '(id = ? OR server_id = ?) AND user_id = ?',
      whereArgs: activeUserId == null ? [id, id] : [id, id, activeUserId],
    );
  }

  static Future<int?> findSaleIdByPayload(Map<String, dynamic> sale) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();

    final customerName = sale['customer_name'] ?? sale['customer'];
    final saleDate = sale['sale_date'] ?? sale['date'];

    final rows = await db.query(
      'sales',
      columns: ['id'],
      where:
          'product_name = ? AND quantity = ? AND unit = ? AND price = ? AND total_amount = ? AND customer_name = ? AND sale_date = ?${activeUserId == null ? '' : ' AND user_id = ?'}',
      whereArgs: activeUserId == null
          ? [
              sale['product_name'],
              sale['quantity'],
              sale['unit'],
              sale['price'],
              sale['total_amount'],
              customerName,
              saleDate,
            ]
          : [
              sale['product_name'],
              sale['quantity'],
              sale['unit'],
              sale['price'],
              sale['total_amount'],
              customerName,
              saleDate,
              activeUserId,
            ],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return rows.first['id'] as int?;
  }

  static Future<int?> findSaleIdByServerId(int serverId) async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    final rows = await db.query(
      'sales',
      columns: ['id'],
      where: activeUserId == null
          ? 'server_id = ?'
          : 'server_id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [serverId] : [serverId, activeUserId],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return rows.first['id'] as int?;
  }

  static Future<List<Map<String, dynamic>>> getRevenueByType() async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    return db.rawQuery('''
      SELECT
        COALESCE(NULLIF(type, ''), 'Other') AS label,
        COUNT(*) AS entry_count,
        SUM(COALESCE(total_amount, 0)) AS total
      FROM sales
      ${activeUserId == null ? '' : 'WHERE user_id = ?'}
      GROUP BY COALESCE(NULLIF(type, ''), 'Other')
      ORDER BY total DESC, label ASC
    ''', activeUserId == null ? null : [activeUserId]);
  }

  static Future<List<Map<String, dynamic>>> getExpensesByCategory() async {
    final db = await _dbHelper.database;
    final activeUserId = await _getActiveUserId();
    return db.rawQuery('''
      SELECT
        COALESCE(NULLIF(category, ''), 'Other') AS label,
        COUNT(*) AS entry_count,
        SUM(COALESCE(amount, 0)) AS total
      FROM expenses
      ${activeUserId == null ? '' : 'WHERE user_id = ?'}
      GROUP BY COALESCE(NULLIF(category, ''), 'Other')
      ORDER BY total DESC, label ASC
    ''', activeUserId == null ? null : [activeUserId]);
  }

  // Pending sales (offline sync queue)
  static Future<int> insertPendingSale(Map<String, dynamic> sale) async {
    if ((sale['product_name'] as String?)?.trim().isEmpty ?? true) {
      throw Exception('Cannot enqueue sale without product_name');
    }

    final db = await _dbHelper.database;
    final activeUserId = await _localSessionService.getActiveUserId();
    return await db.insert(
      'pending_sales',
      {
        'payload': jsonEncode(sale),
        'user_id': activeUserId,
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getPendingSales() async {
    final db = await _dbHelper.database;
    final activeUserId = await _localSessionService.getActiveUserId();
    final List<Map<String, dynamic>> maps = await db.query(
      'pending_sales',
      where: activeUserId == null ? null : 'user_id = ?',
      whereArgs: activeUserId == null ? null : [activeUserId],
      orderBy: 'created_at ASC',
    );
    return maps;
  }

  static Future<int> deletePendingSale(int id) async {
    final db = await _dbHelper.database;
    final activeUserId = await _localSessionService.getActiveUserId();
    return await db.delete(
      'pending_sales',
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [id] : [id, activeUserId],
    );
  }

  static Future<void> cleanupInvalidSales() async {
    final db = await _dbHelper.database;
    final activeUserId = await _localSessionService.getActiveUserId();

    final rows = await db.query(
      'pending_sales',
      where: activeUserId == null ? null : 'user_id = ?',
      whereArgs: activeUserId == null ? null : [activeUserId],
    );

    for (final row in rows) {
      final rawPayload = row['payload'] as String?;
      if (rawPayload == null) {
        await LocalData.deletePendingSale(row['id'] as int);
        continue;
      }

      final Map<String, dynamic> payload =
          jsonDecode(rawPayload) as Map<String, dynamic>;

      if ((payload['product_name'] as String?)?.trim().isEmpty ?? true) {
        await db.delete(
          'pending_sales',
          where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
          whereArgs:
              activeUserId == null ? [row['id']] : [row['id'], activeUserId],
        );
      }
    }
  }
}
