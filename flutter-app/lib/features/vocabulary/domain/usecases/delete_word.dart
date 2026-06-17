import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../repositories/vocabulary_repository.dart';

class DeleteWord {
  final VocabularyRepository repository;
  DeleteWord(this.repository);

  Future<Result<void, Failure>> call(String id) async {
    return repository.deleteWord(id);
  }
}
