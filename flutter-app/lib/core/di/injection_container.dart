import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../features/vocabulary/data/datasources/vocabulary_firestore_datasource.dart';
import '../../features/vocabulary/data/datasources/vocabulary_remote_datasource.dart';
import '../../features/vocabulary/data/repositories/vocabulary_repository_impl.dart';
import '../../features/vocabulary/domain/repositories/vocabulary_repository.dart';
import '../../features/vocabulary/domain/usecases/get_words_from_api.dart';
import '../../features/vocabulary/domain/usecases/save_word.dart';
import '../../features/vocabulary/domain/usecases/watch_saved_words.dart';
import '../../features/vocabulary/domain/usecases/delete_word.dart';
import '../../features/vocabulary/domain/usecases/toggle_favorite.dart';
import '../../features/vocabulary/presentation/bloc/vocabulary_bloc.dart';

final sl = GetIt.instance;

/// The production-ready external API base URL.
/// We use MockAPI for this project to eliminate the need for a local Node.js server.
const String _apiBaseUrl = 'https://6613340f252ec00427c387f6.mockapi.io/api/v1';

Future<void> init({bool useMockFirebase = false}) async {
  // State Management (BLoC)
  sl.registerFactory(
    () => VocabularyBloc(
      getWordsFromAPI: sl(),
      watchSavedWords: sl(),
      saveWord: sl(),
      deleteWord: sl(),
      toggleFavorite: sl(),
      analytics: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetWordsFromAPI(sl()));
  sl.registerLazySingleton(() => WatchSavedWords(sl()));
  sl.registerLazySingleton(() => SaveWord(sl()));
  sl.registerLazySingleton(() => DeleteWord(sl()));
  sl.registerLazySingleton(() => ToggleFavorite(sl()));

  // Repositories
  sl.registerLazySingleton<VocabularyRepository>(
    () => VocabularyRepositoryImpl(
      remoteDataSource: sl(),
      firestoreDataSource: sl(),
      connectivity: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<VocabularyRemoteDataSource>(
    () => VocabularyRemoteDataSourceImpl(dio: sl()),
  );

  if (useMockFirebase) {
    sl.registerLazySingleton<VocabularyFirestoreDataSource>(
      () => MockVocabularyFirestoreDataSourceImpl(),
    );
  } else {
    sl.registerLazySingleton<VocabularyFirestoreDataSource>(
      () => VocabularyFirestoreDataSourceImpl(firestore: sl()),
    );
    sl.registerLazySingleton(() => FirebaseFirestore.instance);
  }

  // Core / External clients
  final dio = Dio(
    BaseOptions(
      baseUrl: _apiBaseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Enable request/response console logger for debugging
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint(obj.toString()),
    ),
  );

  sl.registerLazySingleton(() => dio);
  sl.registerLazySingleton(() => FirebaseAnalytics.instance);
  sl.registerLazySingleton(() => Connectivity());
}
