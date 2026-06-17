import 'package:equatable/equatable.dart';
import '../../domain/entities/vocabulary_word.dart';

/// BLoC States for the Vocabulary feature.
abstract class VocabularyState extends Equatable {
  final List<VocabularyWord> savedWords;
  final List<VocabularyWord> filteredWords;
  final List<VocabularyWord> apiWords;
  final String errorMessage;
  final String searchQuery;
  final VocabularySortType sortType;

  const VocabularyState({
    this.savedWords = const [],
    this.filteredWords = const [],
    this.apiWords = const [],
    this.errorMessage = '',
    this.searchQuery = '',
    this.sortType = VocabularySortType.newest,
  });

  @override
  List<Object?> get props => [
        savedWords,
        filteredWords,
        apiWords,
        errorMessage,
        searchQuery,
        sortType,
      ];
}

enum VocabularySortType { newest, oldest, alphabetical }

class VocabularyInitial extends VocabularyState {}

class VocabularyLoading extends VocabularyState {
  const VocabularyLoading({
    super.savedWords,
    super.filteredWords,
    super.apiWords,
    super.searchQuery,
    super.sortType,
  });
}

class VocabularyLoaded extends VocabularyState {
  const VocabularyLoaded({
    required super.savedWords,
    required super.filteredWords,
    required super.apiWords,
    super.searchQuery,
    super.sortType,
  });
}

class VocabularyEmpty extends VocabularyState {
  const VocabularyEmpty({
    super.apiWords,
  });
}

class VocabularyError extends VocabularyState {
  const VocabularyError({
    required super.errorMessage,
    super.savedWords,
    super.filteredWords,
    super.apiWords,
  });
}

class VocabularyAddingWord extends VocabularyState {
  const VocabularyAddingWord({
    required super.savedWords,
    required super.apiWords,
  });
}

class VocabularyAddSuccess extends VocabularyState {
  const VocabularyAddSuccess({
    required super.savedWords,
    required super.apiWords,
  });
}

class VocabularyAddFailure extends VocabularyState {
  const VocabularyAddFailure({
    required super.errorMessage,
    required super.savedWords,
    required super.apiWords,
  });
}
