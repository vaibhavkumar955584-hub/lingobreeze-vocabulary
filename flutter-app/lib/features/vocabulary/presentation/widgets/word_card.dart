import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/vocabulary_word.dart';
import '../pages/word_details_page.dart';

class WordCard extends StatefulWidget {
  final VocabularyWord word;
  final bool isSaved;
  final VoidCallback? onSave;
  final Function(bool)? onFavoriteToggle;
  final VoidCallback? onDelete;

  const WordCard({
    super.key,
    required this.word,
    this.isSaved = true,
    this.onSave,
    this.onFavoriteToggle,
    this.onDelete,
  });

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  final FlutterTts flutterTts = FlutterTts();

  Future<void> _speak() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(widget.word.word);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      child: Card(
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WordDetailsPage(word: widget.word))),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildStatusBadge(widget.word.status),
                    const Spacer(),
                    if (widget.isSaved)
                      IconButton(
                        onPressed: () => widget.onFavoriteToggle?.call(!widget.word.isFavorite),
                        icon: Icon(widget.word.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, 
                                   color: widget.word.isFavorite ? AppColors.error : AppColors.textSecondary, size: 20),
                      )
                    else
                      IconButton(onPressed: widget.onSave, icon: const Icon(Icons.add_circle_outline, color: AppColors.primary)),
                  ],
                ),
                Text(widget.word.word, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                Text(widget.word.translation, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
                const SizedBox(height: AppSpacing.md),
                if (widget.isSaved) _buildMasteryBar(widget.word.accuracy),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _buildTag(widget.word.category),
                    const Spacer(),
                    IconButton.filledTonal(
                      onPressed: _speak,
                      icon: const Icon(Icons.volume_up_rounded, size: 16),
                      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildStatusBadge(LearningStatus status) {
    String label; Color color;
    switch (status) {
      case LearningStatus.mastered: label = "MASTERED"; color = AppColors.success; break;
      case LearningStatus.learning: label = "LEARNING"; color = AppColors.warning; break;
      case LearningStatus.notStarted: label = "NEW"; color = AppColors.info; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildMasteryBar(double accuracy) {
    int filled = (accuracy / 10).round();
    String bar = "█" * filled + "░" * (10 - filled);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(bar, style: TextStyle(color: AppColors.primary.withValues(alpha: 0.5), letterSpacing: 2, fontSize: 12)),
        const SizedBox(height: 2),
        Text("${accuracy.toInt()}% Mastery", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
    );
  }
}
