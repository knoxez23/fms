// Use-case: get overview data for dashboard
import 'package:pamoja_twalima/data/repositories/local_data.dart';

class GetOverview {
  GetOverview();

  Future<Map<String, dynamic>> execute() async {
    final summary = await LocalData.getFarmSummary();
    return {
      'totalCrops': summary['crops'] ?? 0,
      'totalAnimals': summary['livestock'] ?? 0,
      'balance': summary['monthlySales'] ?? 0.0,
      'pendingTasks': summary['pendingTasks'] ?? 0,
      'lowStockItems': 0, // placeholder until inventory implemented
    };
  }
}

