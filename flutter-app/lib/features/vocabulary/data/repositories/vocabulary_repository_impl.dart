import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/vocabulary_word.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import '../datasources/vocabulary_firestore_datasource.dart';
import '../datasources/vocabulary_remote_datasource.dart';
import '../models/vocabulary_word_model.dart';

class VocabularyRepositoryImpl implements VocabularyRepository {
  final VocabularyRemoteDataSource remoteDataSource;
  final VocabularyFirestoreDataSource firestoreDataSource;
  final Box _cacheBox;
  final Connectivity _connectivity;

  VocabularyRepositoryImpl({
    required this.remoteDataSource,
    required this.firestoreDataSource,
    Box? cacheBox,
    Connectivity? connectivity,
  }) : _cacheBox = cacheBox ?? Hive.box('vocabulary_cache'),
       _connectivity = connectivity ?? Connectivity();

  @override
  Future<Result<List<VocabularyWord>, Failure>> getWordsFromAPI({
    int page = 1,
    String? category,
  }) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final isOffline = connectivityResult == ConnectivityResult.none;

    if (!isOffline) {
      try {
        final models = await remoteDataSource.getWordsFromAPI();
        // Update cache on success
        await _cacheBox.put(
          'discover_words',
          models.map((m) => m.toJson()).toList(),
        );
        return Ok(models);
      } catch (e) {
        // Fallback to cache if API fails while online
        final cacheResult = await _loadFromCache();
        if (cacheResult.isSuccess) return cacheResult;

        return Err(ServerFailure(e.toString()));
      }
    } else {
      // Direct load from cache if offline
      return _loadFromCache();
    }
  }

  Future<Result<List<VocabularyWord>, Failure>> _loadFromCache() async {
    final cachedData = _cacheBox.get('discover_words');
    if (cachedData != null) {
      try {
        final List<VocabularyWord> cachedWords = (cachedData as List)
            .map(
              (json) =>
                  VocabularyWordModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();
        return Ok(cachedWords);
      } catch (e) {
        return Err(CacheFailure('Failed to load vocabulary from cache: $e'));
      }
    }
    return const Err(
      NetworkFailure(
        'Unable to load data. Please check your connection and try again.',
      ),
    );
  }

  @override
  Stream<Result<List<VocabularyWord>, Failure>> watchSavedWords() {
    return firestoreDataSource
        .watchSavedWords()
        .map<Result<List<VocabularyWord>, Failure>>((models) {
          return Ok(models);
        })
        .handleError((error) {
          return Err(FirebaseFailure(error.toString()));
        });
  }

  @override
  Future<Result<void, Failure>> saveWord(VocabularyWord word) async {
    try {
      final model = VocabularyWordModel.fromEntity(word);
      await firestoreDataSource.saveWord(model);
      return const Ok(null);
    } catch (e) {
      return Err(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> deleteWord(String id) async {
    try {
      await firestoreDataSource.deleteWord(id);
      return const Ok(null);
    } catch (e) {
      return Err(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> toggleFavorite(
    String id,
    bool isFavorite,
  ) async {
    try {
      await firestoreDataSource.updateWord(id, {'isFavorite': isFavorite});
      return const Ok(null);
    } catch (e) {
      return Err(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> updateStats(
    String id, {
    required bool correct,
  }) async {
    try {
      await firestoreDataSource.updateWord(id, {
        'lastPracticed': Timestamp.now(),
        'totalAttempts': FieldValue.increment(1),
        'correctCount': correct
            ? FieldValue.increment(1)
            : FieldValue.increment(0),
      });
      return const Ok(null);
    } catch (e) {
      return Err(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<VocabularyWord, Failure>> getWordOfTheDay() async {
    try {
      final words = await remoteDataSource.getWordsFromAPI();
      if (words.isNotEmpty) {
        return Ok(words.first);
      }
      return const Err(ServerFailure('No words found'));
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }
}
