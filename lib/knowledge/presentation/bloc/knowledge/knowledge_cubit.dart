import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../application/knowledge_usecases.dart';
import '../../../domain/entities/knowledge_topic.dart';

class KnowledgeState {
  final List<KnowledgeTopic> topics;
  final String selectedCategory;
  final String searchQuery;
  final bool loading;
  final String? error;

  const KnowledgeState({
    required this.topics,
    required this.selectedCategory,
    required this.searchQuery,
    required this.loading,
    this.error,
  });

  KnowledgeState copyWith({
    List<KnowledgeTopic>? topics,
    String? selectedCategory,
    String? searchQuery,
    bool? loading,
    String? error,
  }) {
    return KnowledgeState(
      topics: topics ?? this.topics,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  factory KnowledgeState.initial() {
    return const KnowledgeState(
      topics: [],
      selectedCategory: 'All',
      searchQuery: '',
      loading: true,
    );
  }
}

@injectable
class KnowledgeCubit extends Cubit<KnowledgeState> {
  final GetKnowledgeTopics _getTopics;

  KnowledgeCubit(this._getTopics) : super(KnowledgeState.initial());

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final topics = await _getTopics.execute();
      emit(state.copyWith(topics: topics, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: 'Failed to load topics'));
    }
  }

  void selectCategory(String category) {
    emit(state.copyWith(selectedCategory: category));
  }

  void updateSearch(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}
