import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../entities/vocabulary_word.dart';
import '../repositories/vocabulary_repository.dart';

class WatchSavedWords {
  final VocabularyRepository repository;

  WatchSavedWords(this.repository);

  Stream<Result<List<VocabularyWord>, Failure>> call() {
    return repository.watchSavedWords();
  }
}
