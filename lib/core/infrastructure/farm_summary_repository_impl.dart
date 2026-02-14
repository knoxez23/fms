import 'package:injectable/injectable.dart';
import 'package:pamoja_twalima/core/domain/repositories/farm_summary_repository.dart';
import 'package:pamoja_twalima/data/repositories/sync_data.dart';

@LazySingleton(as: FarmSummaryRepository)
class FarmSummaryRepositoryImpl implements FarmSummaryRepository {
  final SyncData _syncData;

  FarmSummaryRepositoryImpl(this._syncData);

  @override
  Future<Map<String, dynamic>> getFarmSummary() async {
    return _syncData.getFarmSummary();
  }
}
