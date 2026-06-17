import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../entities/vocabulary_word.dart';
import '../repositories/vocabulary_repository.dart';

class GetWordsFromAPI {
  final VocabularyRepository repository;

  GetWordsFromAPI(this.repository);

  Future<Result<List<VocabularyWord>, Failure>> call() async {
    return repository.getWordsFromAPI();
  }
}
