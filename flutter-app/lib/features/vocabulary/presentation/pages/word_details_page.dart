import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/vocabulary_word.dart';

class WordDetailsPage extends StatelessWidget {
  final VocabularyWord word;

  const WordDetailsPage({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final FlutterTts flutterTts = FlutterTts();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Word Details"),
        actions: [
          IconButton(
            onPressed: () => flutterTts.speak(word.word),
            icon: const Icon(Icons.volume_up_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                children: [
                  Text(
                    word.word,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    word.translation,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle("Meaning"),
            const SizedBox(height: 8),
            Text(
              word.meaning,
              style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle("Statistics"),
            const SizedBox(height: 16),
            _buildStatRow(
              Icons.calendar_today_rounded,
              "Added on",
              DateFormat('MMM dd, yyyy').format(word.createdAt),
            ),
            _buildStatRow(Icons.category_rounded, "Category", word.category),
            _buildStatRow(
              Icons.fitness_center_rounded,
              "Times Practiced",
              word.totalAttempts.toString(),
            ),
            _buildStatRow(
              Icons.analytics_rounded,
              "Accuracy",
              "${word.accuracy.toStringAsFixed(1)}%",
            ),
            _buildStatRow(
              Icons.star_rounded,
              "Status",
              _getStatusText(word.status),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(LearningStatus status) {
    switch (status) {
      case LearningStatus.notStarted:
        return "Not Started";
      case LearningStatus.learning:
        return "Learning";
      case LearningStatus.mastered:
        return "Mastered";
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppTheme.textMuted,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textMuted),
          const SizedBox(width: 12),
          Text(
            "$label: ",
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
