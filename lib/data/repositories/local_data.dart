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

    final lowStockResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM inventory WHERE min_stock > 0 AND quantity <= min_stock${activeUserId == null ? '' : ' AND user_id = ?'}',
      activeUserId == null ? null : [activeUserId],
    );
    final lowStockItems = Sqflite.firstIntValue(lowStockResult) ?? 0;

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
            THEN COALESCE(quantity, 0)
            ELSE 0
          END
        ) AS milk_stock,
        SUM(
          CASE
            WHEN LOWER(COALESCE(item_name, '')) = 'eggs'
              OR (LOWER(COALESCE(category, '')) = 'poultry' AND LOWER(COALESCE(item_name, '')) LIKE '%egg%')
            THEN COALESCE(quantity, 0)
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
      WHERE COALESCE(quantity, 0) > 0
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

    return {
      "crops": cropCount,
      "livestock": animalCount,
      "inventory": inventoryCount,
      "pendingTasks": pendingTasksCount,
      "salesToday": salesToday,
      "monthlySales": monthlySales,
      "expensesToday": expensesToday,
      "monthlyExpenses": monthlyExpenses,
      "netCashFlowToday": salesToday - expensesToday,
      "monthlyNetCashFlow": monthlySales - monthlyExpenses,
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
      "productionValueToday": productionValueToday,
      "todaysFeedings": todaysFeedings,
      "todaysFeedingPreview": todaysFeedingPreview,
      "setupTasksNext7Days": setupTasksNext7Days,
      "setupTasksNext30Days": setupTasksNext30Days,
      "activeFieldCrops": activeFieldCrops,
      "productionReviewsNext7Days": productionReviewsNext7Days,
      "harvestReadyCrops": harvestReadyCrops,
      "feedReadinessGaps": feedReadinessGaps,
      "cropInputGaps": cropInputGaps,
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

    final insights = <OperationalInsight>[
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
