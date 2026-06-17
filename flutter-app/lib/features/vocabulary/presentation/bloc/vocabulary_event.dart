import 'package:equatable/equatable.dart';
import '../../domain/entities/vocabulary_word.dart';
import 'vocabulary_state.dart';

/// BLoC Events for the Vocabulary feature.
abstract class VocabularyEvent extends Equatable {
  const VocabularyEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the page initially loads.
class LoadWords extends VocabularyEvent {}

/// Triggered to reload suggestions from the Node.js Express API.
class RefreshWords extends VocabularyEvent {}

/// Triggered when saving a new word.
class AddWordEvent extends VocabularyEvent {
  final String word;
  final String meaning;
  final String translation;

  const AddWordEvent({
    required this.word,
    required this.meaning,
    required this.translation,
  });

  @override
  List<Object?> get props => [word, meaning, translation];
}

/// Triggered to toggle favorite status of a word.
class ToggleFavoriteWord extends VocabularyEvent {
  final String id;
  final bool isFavorite;

  const ToggleFavoriteWord(this.id, this.isFavorite);

  @override
  List<Object?> get props => [id, isFavorite];
}

/// Triggered to delete a word.
class DeleteWordEvent extends VocabularyEvent {
  final String id;

  const DeleteWordEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Triggered to search words.
class SearchWords extends VocabularyEvent {
  final String query;

  const SearchWords(this.query);

  @override
  List<Object?> get props => [query];
}

/// Triggered to sort words.
class SortWords extends VocabularyEvent {
  final VocabularySortType sortType;

  const SortWords(this.sortType);

  @override
  List<Object?> get props => [sortType];
}

/// Internal event triggered when the Firestore stream emits new saved words.
class UpdateSavedWords extends VocabularyEvent {
  final List<VocabularyWord> savedWords;

  const UpdateSavedWords(this.savedWords);

  @override
  List<Object?> get props => [savedWords];
}

/// Internal event triggered when the Firestore stream encounters an error.
class UpdateSavedWordsError extends VocabularyEvent {
  final String message;

  const UpdateSavedWordsError(this.message);

  @override
  List<Object?> get props => [message];
}
