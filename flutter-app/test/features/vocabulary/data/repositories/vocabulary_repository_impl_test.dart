import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vocabulary_app/core/errors/failures.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:vocabulary_app/features/vocabulary/data/datasources/vocabulary_firestore_datasource.dart';
import 'package:vocabulary_app/features/vocabulary/data/datasources/vocabulary_remote_datasource.dart';
import 'package:vocabulary_app/features/vocabulary/data/models/vocabulary_word_model.dart';
import 'package:vocabulary_app/features/vocabulary/data/repositories/vocabulary_repository_impl.dart';

class MockRemoteDataSource extends Mock implements VocabularyRemoteDataSource {}

class MockFirestoreDataSource extends Mock
    implements VocabularyFirestoreDataSource {}

class MockBox extends Mock implements Box {}

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late VocabularyRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockFirestoreDataSource mockFirestoreDataSource;
  late MockBox mockBox;
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockFirestoreDataSource = MockFirestoreDataSource();
    mockBox = MockBox();
    mockConnectivity = MockConnectivity();

    // Stub connectivity check
    when(
      () => mockConnectivity.checkConnectivity(),
    ).thenAnswer((_) async => ConnectivityResult.wifi);

    // Stub Hive box put
    when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});

    repository = VocabularyRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      firestoreDataSource: mockFirestoreDataSource,
      cacheBox: mockBox,
      connectivity: mockConnectivity,
    );
  });

  group('getWordsFromAPI', () {
    final tWordModel = VocabularyWordModel(
      id: '1',
      word: 'Test',
      meaning: 'Test Meaning',
      translation: 'Test Translation',
      createdAt: DateTime.now(),
    );
    final tWordModelList = [tWordModel];

    test(
      'should return remote data when the call to remote data source is successful',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.getWordsFromAPI(),
        ).thenAnswer((_) async => tWordModelList);
        // act
        final result = await repository.getWordsFromAPI();
        // assert
        verify(() => mockRemoteDataSource.getWordsFromAPI());
        expect(result.isSuccess, true);
        result.fold(
          (success) => expect(success, tWordModelList),
          (failure) => fail('Should not return failure'),
        );
      },
    );

    test(
      'should return ServerFailure when the call to remote data source is unsuccessful',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.getWordsFromAPI(),
        ).thenThrow(Exception());
        // act
        final result = await repository.getWordsFromAPI();
        // assert
        verify(() => mockRemoteDataSource.getWordsFromAPI());
        expect(result.isFailure, true);
        result.fold(
          (success) => fail('Should not return success'),
          (failure) => expect(failure, isA<ServerFailure>()),
        );
      },
    );
  });
}
