// Use-case: get overview data for dashboard
import 'package:injectable/injectable.dart';
import 'package:pamoja_twalima/core/domain/repositories/farm_summary_repository.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/overview_summary_entity.dart';

@lazySingleton
class GetOverview {
  final FarmSummaryRepository _farmSummaryRepository;

  GetOverview(this._farmSummaryRepository);

  Future<OverviewSummaryEntity> execute() async {
    final summary = await _farmSummaryRepository.getFarmSummary();
    return OverviewSummaryEntity(
      totalCrops: (summary['crops'] as num?)?.toInt() ?? 0,
      totalAnimals: (summary['livestock'] as num?)?.toInt() ?? 0,
      balance: (summary['monthlySales'] as num?)?.toDouble() ?? 0.0,
      pendingTasks: (summary['pendingTasks'] as num?)?.toInt() ?? 0,
      lowStockItems: (summary['lowStockItems'] as num?)?.toInt() ?? 0,
    );
  }
}
