import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../entities/vocabulary_word.dart';
import '../repositories/vocabulary_repository.dart';

class SaveWord {
  final VocabularyRepository repository;

  SaveWord(this.repository);

  Future<Result<void, Failure>> call(VocabularyWord word) async {
    return repository.saveWord(word);
  }
}
