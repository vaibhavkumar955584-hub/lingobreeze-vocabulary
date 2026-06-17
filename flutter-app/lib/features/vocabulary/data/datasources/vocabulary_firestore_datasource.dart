import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vocabulary_word_model.dart';

/// Data Source interface for Firebase Firestore operations.
abstract class VocabularyFirestoreDataSource {
  Stream<List<VocabularyWordModel>> watchSavedWords();
  Future<void> saveWord(VocabularyWordModel word);
  Future<void> deleteWord(String id);
  Future<void> updateWord(String id, Map<String, dynamic> data);
}

/// Implementation using standard Firestore SDK.
class VocabularyFirestoreDataSourceImpl implements VocabularyFirestoreDataSource {
  final FirebaseFirestore firestore;

  VocabularyFirestoreDataSourceImpl({required this.firestore});

  @override
  Stream<List<VocabularyWordModel>> watchSavedWords() {
    return firestore
        .collection('vocabulary')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => VocabularyWordModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<void> saveWord(VocabularyWordModel word) async {
    if (word.id.isEmpty) {
      await firestore.collection('vocabulary').add(word.toFirestore());
    } else {
      await firestore
          .collection('vocabulary')
          .doc(word.id)
          .set(word.toFirestore());
    }
  }

  @override
  Future<void> deleteWord(String id) async {
    await firestore.collection('vocabulary').doc(id).delete();
  }

  @override
  Future<void> updateWord(String id, Map<String, dynamic> data) async {
    await firestore.collection('vocabulary').doc(id).update(data);
  }
}

/// Fallback Mock Implementation
class MockVocabularyFirestoreDataSourceImpl implements VocabularyFirestoreDataSource {
  final StreamController<List<VocabularyWordModel>> _controller =
      StreamController<List<VocabularyWordModel>>.broadcast();

  final List<VocabularyWordModel> _mockSavedWords = [];

  MockVocabularyFirestoreDataSourceImpl() {
    _mockSavedWords.addAll([
      VocabularyWordModel(
        id: 'mock-1',
        word: 'Serendipity',
        meaning: 'The occurrence and development of events by chance in a happy or beneficial way.',
        translation: 'Serendipia',
        isFavorite: true,
        category: 'English',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      VocabularyWordModel(
        id: 'mock-2',
        word: 'Ephemeral',
        meaning: 'Lasting for a very short time.',
        translation: 'Efímero',
        category: 'Literature',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
  }

  @override
  Stream<List<VocabularyWordModel>> watchSavedWords() {
    Timer.run(() {
      if (!_controller.isClosed) {
        _controller.add(List.unmodifiable(_mockSavedWords));
      }
    });
    return _controller.stream;
  }

  @override
  Future<void> saveWord(VocabularyWordModel word) async {
    final index = _mockSavedWords.indexWhere((w) => w.id == word.id && word.id.isNotEmpty);
    if (index != -1) {
      _mockSavedWords[index] = word;
    } else {
      final newModel = VocabularyWordModel(
        id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
        word: word.word,
        meaning: word.meaning,
        translation: word.translation,
        isFavorite: word.isFavorite,
        category: word.category,
        createdAt: word.createdAt,
      );
      _mockSavedWords.insert(0, newModel);
    }
    _controller.add(List.unmodifiable(_mockSavedWords));
  }

  @override
  Future<void> deleteWord(String id) async {
    _mockSavedWords.removeWhere((w) => w.id == id);
    _controller.add(List.unmodifiable(_mockSavedWords));
  }

  @override
  Future<void> updateWord(String id, Map<String, dynamic> data) async {
    final index = _mockSavedWords.indexWhere((w) => w.id == id);
    if (index != -1) {
      final current = _mockSavedWords[index];
      _mockSavedWords[index] = VocabularyWordModel(
        id: current.id,
        word: data['word'] ?? current.word,
        meaning: data['meaning'] ?? current.meaning,
        translation: data['translation'] ?? current.translation,
        createdAt: current.createdAt,
        isFavorite: data['isFavorite'] ?? current.isFavorite,
        category: data['category'] ?? current.category,
        totalAttempts: data['totalAttempts'] ?? current.totalAttempts,
        correctCount: data['correctCount'] ?? current.correctCount,
        lastPracticed: data['lastPracticed'] is DateTime 
            ? data['lastPracticed'] 
            : current.lastPracticed,
      );
      _controller.add(List.unmodifiable(_mockSavedWords));
    }
  }
}
