import '../entities/knowledge_topic.dart';

abstract class KnowledgeRepository {
  Future<List<KnowledgeTopic>> getTopics();
}
