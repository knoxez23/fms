import 'package:injectable/injectable.dart';
import '../domain/entities/knowledge_topic.dart';
import '../domain/repositories/knowledge_repository.dart';
import '../../../data/services/knowledge_service.dart';

@LazySingleton(as: KnowledgeRepository)
class KnowledgeRepositoryImpl implements KnowledgeRepository {
  final KnowledgeService _service;

  KnowledgeRepositoryImpl(this._service);

  @override
  Future<List<KnowledgeTopic>> getTopics() async {
    final items = await _service.fetchTopics();
    return items.map(_mapToEntity).toList();
  }

  KnowledgeTopic _mapToEntity(Map<String, dynamic> map) {
    return KnowledgeTopic(
      title: (map['title'] ?? 'Untitled').toString(),
      subtitle: (map['subtitle'] ?? map['summary'] ?? '').toString(),
      category: (map['category'] ?? 'General').toString(),
      readTime: (map['read_time'] ?? map['readTime'] ?? '5 min read').toString(),
      iconKey: (map['icon_key'] ?? map['iconKey'] ?? 'agriculture').toString(),
    );
  }
}
