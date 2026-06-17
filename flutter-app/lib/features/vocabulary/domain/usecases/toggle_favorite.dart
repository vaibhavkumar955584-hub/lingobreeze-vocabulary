import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../repositories/vocabulary_repository.dart';

class ToggleFavorite {
  final VocabularyRepository repository;
  ToggleFavorite(this.repository);

  Future<Result<void, Failure>> call(String id, bool isFavorite) async {
    return repository.toggleFavorite(id, isFavorite);
  }
}
