import '../entities/vocabulary_word.dart';

class StreakService {
  int calculateCurrentStreak(List<VocabularyWord> words) {
    if (words.isEmpty) return 0;

    final practiceDates = words
        .where((w) => w.lastPracticed != null)
        .map((w) => DateTime(w.lastPracticed!.year, w.lastPracticed!.month, w.lastPracticed!.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (practiceDates.isEmpty) return 0;

    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    
    // Check if the latest practice was today or yesterday
    if (practiceDates.first.isBefore(todayMidnight.subtract(const Duration(days: 1)))) {
      return 0;
    }

    int streak = 0;
    DateTime currentDay = practiceDates.first;

    for (final date in practiceDates) {
      if (date == currentDay) {
        streak++;
        currentDay = currentDay.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  double calculateOverallAccuracy(List<VocabularyWord> words) {
    int total = 0;
    int correct = 0;
    for (var w in words) {
      total += w.totalAttempts;
      correct += w.correctCount;
    }
    return total == 0 ? 0.0 : (correct / total) * 100;
  }
}
