import 'package:pamoja_twalima/features/home/domain/entities/dashboard_data.dart';

abstract class FarmSummaryRepository {
  Future<Map<String, dynamic>> getFarmSummary();
  Future<List<OperationalInsight>> getOperationalInsights();
}
