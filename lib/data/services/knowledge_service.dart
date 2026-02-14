import 'package:injectable/injectable.dart';
import '../network/api_service.dart';

@LazySingleton()
class KnowledgeService {
  final ApiService _api;

  KnowledgeService(this._api);

  Future<List<Map<String, dynamic>>> fetchTopics() async {
    final response = await _api.get('/knowledge/topics');
    final data = response.data;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}
