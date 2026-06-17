import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:vocabulary_app/core/errors/result.dart';
import 'package:vocabulary_app/features/vocabulary/domain/entities/vocabulary_word.dart';
import 'package:vocabulary_app/features/vocabulary/domain/usecases/get_words_from_api.dart';
import 'package:vocabulary_app/features/vocabulary/domain/usecases/save_word.dart';
import 'package:vocabulary_app/features/vocabulary/domain/usecases/watch_saved_words.dart';
import 'package:vocabulary_app/features/vocabulary/domain/usecases/delete_word.dart';
import 'package:vocabulary_app/features/vocabulary/domain/usecases/toggle_favorite.dart';
import 'package:vocabulary_app/features/vocabulary/presentation/bloc/vocabulary_bloc.dart';
import 'package:vocabulary_app/features/vocabulary/presentation/bloc/vocabulary_event.dart';
import 'package:vocabulary_app/features/vocabulary/presentation/bloc/vocabulary_state.dart';

class MockGetWordsFromAPI extends Mock implements GetWordsFromAPI {}
class MockWatchSavedWords extends Mock implements WatchSavedWords {}
class MockSaveWord extends Mock implements SaveWord {}
class MockDeleteWord extends Mock implements DeleteWord {}
class MockToggleFavorite extends Mock implements ToggleFavorite {}
class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  late MockGetWordsFromAPI mockGetWordsFromAPI;
  late MockWatchSavedWords mockWatchSavedWords;
  late MockSaveWord mockSaveWord;
  late MockDeleteWord mockDeleteWord;
  late MockToggleFavorite mockToggleFavorite;
  late MockFirebaseAnalytics mockAnalytics;
  late VocabularyBloc bloc;

  setUpAll(() {
    registerFallbackValue(
      VocabularyWord(
        id: '',
        word: '',
        meaning: '',
        translation: '',
        createdAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockGetWordsFromAPI = MockGetWordsFromAPI();
    mockWatchSavedWords = MockWatchSavedWords();
    mockSaveWord = MockSaveWord();
    mockDeleteWord = MockDeleteWord();
    mockToggleFavorite = MockToggleFavorite();
    mockAnalytics = MockFirebaseAnalytics();

    // Stub analytics calls
    when(() => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        )).thenAnswer((_) async => {});

    bloc = VocabularyBloc(
      getWordsFromAPI: mockGetWordsFromAPI,
      watchSavedWords: mockWatchSavedWords,
      saveWord: mockSaveWord,
      deleteWord: mockDeleteWord,
      toggleFavorite: mockToggleFavorite,
      analytics: mockAnalytics,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state should be VocabularyInitial', () {
    expect(bloc.state, equals(VocabularyInitial()));
  });

  group('AddWord Event Tests', () {
    blocTest<VocabularyBloc, VocabularyState>(
      'should emit [VocabularyAddingWord, VocabularyAddSuccess, VocabularyEmpty] when word is saved successfully',
      build: () {
        when(() => mockSaveWord(any()))
            .thenAnswer((_) async => const Ok(null));
        return bloc;
      },
      act: (blocInstance) => blocInstance.add(
        const AddWordEvent(
          word: 'Apple',
          meaning: 'A round fruit',
          translation: 'Manzana',
        ),
      ),
      expect: () => [
        const VocabularyAddingWord(savedWords: [], apiWords: []),
        const VocabularyAddSuccess(savedWords: [], apiWords: []),
        const VocabularyEmpty(apiWords: []),
      ],
    );
  });
}
