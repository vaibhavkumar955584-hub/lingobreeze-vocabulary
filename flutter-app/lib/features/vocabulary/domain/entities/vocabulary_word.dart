import 'package:equatable/equatable.dart';

enum LearningStatus { notStarted, learning, mastered }

class VocabularyWord extends Equatable {
  final String id;
  final String word;
  final String meaning;
  final String translation;
  final String category;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime? lastPracticed;
  final LearningStatus status;
  final int correctCount;
  final int totalAttempts;

  const VocabularyWord({
    required this.id,
    required this.word,
    required this.meaning,
    required this.translation,
    this.category = 'General',
    this.isFavorite = false,
    required this.createdAt,
    this.lastPracticed,
    this.status = LearningStatus.notStarted,
    this.correctCount = 0,
    this.totalAttempts = 0,
  });

  double get accuracy =>
      totalAttempts == 0 ? 0.0 : (correctCount / totalAttempts) * 100;

  VocabularyWord copyWith({
    String? id,
    String? word,
    String? meaning,
    String? translation,
    String? category,
    bool? isFavorite,
    DateTime? lastPracticed,
    LearningStatus? status,
    int? correctCount,
    int? totalAttempts,
  }) {
    return VocabularyWord(
      id: id ?? this.id,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      translation: translation ?? this.translation,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
      lastPracticed: lastPracticed ?? this.lastPracticed,
      status: status ?? this.status,
      correctCount: correctCount ?? this.correctCount,
      totalAttempts: totalAttempts ?? this.totalAttempts,
    );
  }

  @override
  List<Object?> get props => [
    id,
    word,
    meaning,
    translation,
    category,
    isFavorite,
    createdAt,
    lastPracticed,
    status,
    correctCount,
    totalAttempts,
  ];
}
