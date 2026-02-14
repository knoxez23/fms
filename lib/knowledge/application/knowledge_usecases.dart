import 'package:injectable/injectable.dart';
import '../domain/entities/knowledge_topic.dart';
import '../domain/repositories/knowledge_repository.dart';

@lazySingleton
class GetKnowledgeTopics {
  final KnowledgeRepository repository;
  GetKnowledgeTopics(this.repository);

  Future<List<KnowledgeTopic>> execute() async {
    return await repository.getTopics();
  }
}
