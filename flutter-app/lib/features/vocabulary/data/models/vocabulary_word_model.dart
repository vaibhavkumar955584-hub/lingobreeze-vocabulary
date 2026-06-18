import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/vocabulary_word.dart';

class VocabularyWordModel extends VocabularyWord {
  const VocabularyWordModel({
    required super.id,
    required super.word,
    required super.meaning,
    required super.translation,
    super.category,
    super.isFavorite,
    required super.createdAt,
    super.lastPracticed,
    super.status,
    super.correctCount,
    super.totalAttempts,
  });

  factory VocabularyWordModel.fromJson(Map<String, dynamic> json) {
    return VocabularyWordModel(
      id: json['id'] ?? '',
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      translation: json['translation'] ?? '',
      category: json['category'] ?? 'General',
      isFavorite: json['isFavorite'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastPracticed: json['lastPracticed'] != null
          ? DateTime.parse(json['lastPracticed'])
          : null,
      status: LearningStatus.values.firstWhere(
        (e) => e.toString() == (json['status'] ?? 'LearningStatus.notStarted'),
        orElse: () => LearningStatus.notStarted,
      ),
      correctCount: json['correctCount'] ?? 0,
      totalAttempts: json['totalAttempts'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'meaning': meaning,
      'translation': translation,
      'category': category,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'lastPracticed': lastPracticed?.toIso8601String(),
      'status': status.toString(),
      'correctCount': correctCount,
      'totalAttempts': totalAttempts,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'word': word,
      'meaning': meaning,
      'translation': translation,
      'category': category,
      'isFavorite': isFavorite,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastPracticed': lastPracticed != null
          ? Timestamp.fromDate(lastPracticed!)
          : null,
      'status': status.toString(),
      'correctCount': correctCount,
      'totalAttempts': totalAttempts,
    };
  }

  factory VocabularyWordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VocabularyWordModel(
      id: doc.id,
      word: data['word'] ?? '',
      meaning: data['meaning'] ?? '',
      translation: data['translation'] ?? '',
      category: data['category'] ?? 'General',
      isFavorite: data['isFavorite'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastPracticed: (data['lastPracticed'] as Timestamp?)?.toDate(),
      status: LearningStatus.values.firstWhere(
        (e) => e.toString() == (data['status'] ?? 'LearningStatus.notStarted'),
        orElse: () => LearningStatus.notStarted,
      ),
      correctCount: data['correctCount'] ?? 0,
      totalAttempts: data['totalAttempts'] ?? 0,
    );
  }

  factory VocabularyWordModel.fromEntity(VocabularyWord entity) {
    return VocabularyWordModel(
      id: entity.id,
      word: entity.word,
      meaning: entity.meaning,
      translation: entity.translation,
      category: entity.category,
      isFavorite: entity.isFavorite,
      createdAt: entity.createdAt,
      lastPracticed: entity.lastPracticed,
      status: entity.status,
      correctCount: entity.correctCount,
      totalAttempts: entity.totalAttempts,
    );
  }
}
