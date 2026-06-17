import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../entities/vocabulary_word.dart';

/// Repository interface defining the data operations contract.
abstract class VocabularyRepository {
  /// Fetches suggestions/sample vocabulary words from the Node.js API.
  Future<Result<List<VocabularyWord>, Failure>> getWordsFromAPI({
    int page = 1,
    String? category,
  });

  /// Watches saved vocabulary words inside Firebase Firestore (real-time stream).
  Stream<Result<List<VocabularyWord>, Failure>> watchSavedWords();

  /// Saves a new vocabulary word to Firebase Firestore.
  Future<Result<void, Failure>> saveWord(VocabularyWord word);

  /// Deletes a vocabulary word.
  Future<Result<void, Failure>> deleteWord(String id);

  /// Toggles favorite status of a word.
  Future<Result<void, Failure>> toggleFavorite(String id, bool isFavorite);

  /// Updates practice stats for a word.
  Future<Result<void, Failure>> updateStats(String id, {required bool correct});

  /// Gets local word of the day from cache or API.
  Future<Result<VocabularyWord, Failure>> getWordOfTheDay();
}
