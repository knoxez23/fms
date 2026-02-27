import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../application/knowledge_usecases.dart';
import '../../../domain/entities/knowledge_topic.dart';

class KnowledgeState {
  final List<KnowledgeTopic> topics;
  final String selectedCategory;
  final String searchQuery;
  final Set<String> bookmarkedTopics;
  final bool loading;
  final String? error;

  const KnowledgeState({
    required this.topics,
    required this.selectedCategory,
    required this.searchQuery,
    required this.bookmarkedTopics,
    required this.loading,
    this.error,
  });

  KnowledgeState copyWith({
    List<KnowledgeTopic>? topics,
    String? selectedCategory,
    String? searchQuery,
    Set<String>? bookmarkedTopics,
    bool? loading,
    String? error,
  }) {
    return KnowledgeState(
      topics: topics ?? this.topics,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      bookmarkedTopics: bookmarkedTopics ?? this.bookmarkedTopics,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  factory KnowledgeState.initial() {
    return const KnowledgeState(
      topics: [],
      selectedCategory: 'All',
      searchQuery: '',
      bookmarkedTopics: <String>{},
      loading: true,
    );
  }
}

@injectable
class KnowledgeCubit extends Cubit<KnowledgeState> {
  final GetKnowledgeTopics _getTopics;
  static const _bookmarkKey = 'knowledge_bookmarks';

  KnowledgeCubit(this._getTopics) : super(KnowledgeState.initial());

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final results = await Future.wait([
        _getTopics.execute(),
        _loadBookmarks(),
      ]);
      final topics = results[0] as List<KnowledgeTopic>;
      final bookmarks = results[1] as Set<String>;
      emit(
        state.copyWith(
          topics: topics,
          bookmarkedTopics: bookmarks,
          loading: false,
        ),
      );
    } catch (e) {
      emit(
          state.copyWith(loading: false, error: 'error_knowledge_load_topics'));
    }
  }

  void selectCategory(String category) {
    emit(state.copyWith(selectedCategory: category));
  }

  void updateSearch(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<void> toggleBookmark(String title) async {
    final updated = Set<String>.from(state.bookmarkedTopics);
    if (updated.contains(title)) {
      updated.remove(title);
    } else {
      updated.add(title);
    }
    emit(state.copyWith(bookmarkedTopics: updated));
    await _saveBookmarks(updated);
  }

  Future<Set<String>> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    return Set<String>.from(prefs.getStringList(_bookmarkKey) ?? <String>[]);
  }

  Future<void> _saveBookmarks(Set<String> topics) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_bookmarkKey, topics.toList()..sort());
  }
}
