import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../domain/entities/vocabulary_word.dart';
import '../../domain/usecases/get_words_from_api.dart';
import '../../domain/usecases/save_word.dart';
import '../../domain/usecases/watch_saved_words.dart';
import '../../domain/usecases/delete_word.dart' as usecase;
import '../../domain/usecases/toggle_favorite.dart';
import 'vocabulary_event.dart';
import 'vocabulary_state.dart';

class VocabularyBloc extends Bloc<VocabularyEvent, VocabularyState> {
  final GetWordsFromAPI _getWordsFromAPI;
  final WatchSavedWords _watchSavedWords;
  final SaveWord _saveWord;
  final usecase.DeleteWord _deleteWord;
  final ToggleFavorite _toggleFavorite;
  final FirebaseAnalytics _analytics;

  StreamSubscription? _savedWordsSubscription;
  List<VocabularyWord> _allSavedWords = [];
  List<VocabularyWord> _apiWords = [];
  final Set<String> _recentlyShownWordIds = {};
  bool _isApiLoading = false;

  VocabularyBloc({
    required GetWordsFromAPI getWordsFromAPI,
    required WatchSavedWords watchSavedWords,
    required SaveWord saveWord,
    required usecase.DeleteWord deleteWord,
    required ToggleFavorite toggleFavorite,
    FirebaseAnalytics? analytics,
  })  : _getWordsFromAPI = getWordsFromAPI,
        _watchSavedWords = watchSavedWords,
        _saveWord = saveWord,
        _deleteWord = deleteWord,
        _toggleFavorite = toggleFavorite,
        _analytics = analytics ?? FirebaseAnalytics.instance,
        super(VocabularyInitial()) {
    on<LoadWords>(_onLoadWords);
    on<RefreshWords>(_onRefreshWords);
    on<AddWordEvent>(_onAddWord);
    on<DeleteWordEvent>(_onDeleteWord);
    on<ToggleFavoriteWord>(_onToggleFavorite);
    on<SearchWords>(_onSearchWords);
    on<SortWords>(_onSortWords);
    on<UpdateSavedWords>(_onUpdateSavedWords);
    on<UpdateSavedWordsError>(_onUpdateSavedWordsError);
  }

  Future<void> _onLoadWords(LoadWords event, Emitter<VocabularyState> emit) async {
    _isApiLoading = true;
    emit(VocabularyLoading(
      savedWords: _allSavedWords,
      filteredWords: state.filteredWords,
      apiWords: _apiWords,
      searchQuery: state.searchQuery,
      sortType: state.sortType,
    ));

    await _savedWordsSubscription?.cancel();
    _savedWordsSubscription = _watchSavedWords().listen(
      (result) {
        result.fold(
          (words) => add(UpdateSavedWords(words)),
          (failure) => add(UpdateSavedWordsError(failure.message)),
        );
      },
    );

    final apiResult = await _getWordsFromAPI();
    _isApiLoading = false;
    
    apiResult.fold(
      (words) {
        _apiWords = List.from(words)..shuffle();
        _updateRecentlyShown(_apiWords);
        _emitCurrentState(emit);
      },
      (failure) => emit(VocabularyError(
        errorMessage: failure.message,
        savedWords: _allSavedWords,
        apiWords: _apiWords,
      )),
    );
  }

  Future<void> _onRefreshWords(RefreshWords event, Emitter<VocabularyState> emit) async {
    _isApiLoading = true;
    emit(VocabularyLoading(
      savedWords: _allSavedWords,
      filteredWords: state.filteredWords,
      apiWords: _apiWords,
      searchQuery: state.searchQuery,
      sortType: state.sortType,
    ));

    final apiResult = await _getWordsFromAPI();
    _isApiLoading = false;

    apiResult.fold(
      (words) {
        // Shuffle the pool
        final pool = List<VocabularyWord>.from(words)..shuffle();
        
        // Try to find words not recently shown
        final freshWords = pool.where((w) => !_recentlyShownWordIds.contains(w.id)).toList();
        
        if (freshWords.length >= 5) {
          _apiWords = freshWords.take(10).toList();
        } else {
          // If not enough fresh words, clear history and use the shuffled pool
          _recentlyShownWordIds.clear();
          _apiWords = pool.take(10).toList();
        }
        
        _updateRecentlyShown(_apiWords);
        _emitCurrentState(emit);
      },
      (failure) => emit(VocabularyError(
        errorMessage: failure.message,
        savedWords: _allSavedWords,
        apiWords: _apiWords,
      )),
    );
  }

  void _updateRecentlyShown(List<VocabularyWord> words) {
    for (var w in words) {
      _recentlyShownWordIds.add(w.id);
    }
    // Keep history size manageable (e.g., last 30 words)
    if (_recentlyShownWordIds.length > 30) {
      final toRemove = _recentlyShownWordIds.take(_recentlyShownWordIds.length - 30).toList();
      _recentlyShownWordIds.removeAll(toRemove);
    }
  }

  Future<void> _onAddWord(AddWordEvent event, Emitter<VocabularyState> emit) async {
    emit(VocabularyAddingWord(
      savedWords: _allSavedWords,
      apiWords: _apiWords,
    ));

    final word = VocabularyWord(
      id: '',
      word: event.word.trim(),
      meaning: event.meaning.trim(),
      translation: event.translation.trim(),
      createdAt: DateTime.now(),
    );

    await _analytics.logEvent(name: 'word_added', parameters: {'word': event.word});
    
    final result = await _saveWord(word);
    
    result.fold(
      (_) {
        emit(VocabularyAddSuccess(
          savedWords: _allSavedWords,
          apiWords: _apiWords,
        ));
        // We don't need to manually update _allSavedWords because the 
        // Firestore stream listener will handle it and trigger UpdateSavedWords.
        _emitCurrentState(emit);
      },
      (failure) => emit(VocabularyAddFailure(
        errorMessage: failure.message,
        savedWords: _allSavedWords,
        apiWords: _apiWords,
      )),
    );
  }

  Future<void> _onDeleteWord(DeleteWordEvent event, Emitter<VocabularyState> emit) async {
    await _analytics.logEvent(name: 'word_deleted', parameters: {'word_id': event.id});
    await _deleteWord(event.id);
  }

  Future<void> _onToggleFavorite(ToggleFavoriteWord event, Emitter<VocabularyState> emit) async {
    await _analytics.logEvent(name: 'word_favorite_toggled', parameters: {'is_favorite': event.isFavorite});
    await _toggleFavorite(event.id, event.isFavorite);
  }

  void _onSearchWords(SearchWords event, Emitter<VocabularyState> emit) {
    if (event.query.length > 2) {
      _analytics.logSearch(searchTerm: event.query);
    }
    _emitCurrentState(emit, searchQuery: event.query);
  }

  void _onSortWords(SortWords event, Emitter<VocabularyState> emit) {
    _emitCurrentState(emit, sortType: event.sortType);
  }

  void _onUpdateSavedWords(UpdateSavedWords event, Emitter<VocabularyState> emit) {
    _allSavedWords = event.savedWords;
    _emitCurrentState(emit);
  }

  void _onUpdateSavedWordsError(UpdateSavedWordsError event, Emitter<VocabularyState> emit) {
    emit(VocabularyError(errorMessage: event.message, savedWords: _allSavedWords));
  }

  void _emitCurrentState(
    Emitter<VocabularyState> emit, {
    String? searchQuery,
    VocabularySortType? sortType,
  }) {
    final query = searchQuery ?? state.searchQuery;
    final sort = sortType ?? state.sortType;

    List<VocabularyWord> filtered = List.from(_allSavedWords);

    if (query.isNotEmpty) {
      filtered = filtered
          .where((w) =>
              w.word.toLowerCase().contains(query.toLowerCase()) ||
              w.translation.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    switch (sort) {
      case VocabularySortType.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case VocabularySortType.oldest:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case VocabularySortType.alphabetical:
        filtered.sort((a, b) => a.word.compareTo(b.word));
    }

    if (_isApiLoading && _apiWords.isEmpty) {
      emit(VocabularyLoading(
        savedWords: _allSavedWords,
        filteredWords: filtered,
        apiWords: _apiWords,
        searchQuery: query,
        sortType: sort,
      ));
    } else if (_allSavedWords.isEmpty && query.isEmpty) {
      emit(VocabularyEmpty(apiWords: _apiWords));
    } else {
      emit(VocabularyLoaded(
        savedWords: _allSavedWords,
        filteredWords: filtered,
        apiWords: _apiWords,
        searchQuery: query,
        sortType: sort,
      ));
    }
  }

  @override
  Future<void> close() {
    _savedWordsSubscription?.cancel();
    return super.close();
  }
}
