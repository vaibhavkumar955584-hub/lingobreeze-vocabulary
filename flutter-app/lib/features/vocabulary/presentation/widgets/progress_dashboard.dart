import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/vocabulary_bloc.dart';
import '../bloc/vocabulary_state.dart';
import '../../domain/entities/vocabulary_word.dart';
import '../../domain/services/streak_service.dart';

class ProgressDashboard extends StatelessWidget {
  const ProgressDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final streakService = StreakService();

    return BlocBuilder<VocabularyBloc, VocabularyState>(
      builder: (context, state) {
        final total = state.savedWords.length;
        final mastered = state.savedWords
            .where((w) => w.status == LearningStatus.mastered)
            .length;
        final learning = state.savedWords
            .where((w) => w.status == LearningStatus.learning)
            .length;

        final xp = (mastered * 50) + (learning * 20) + (total * 10);
        final level = (xp / 500).floor() + 1;
        final progressToNextLevel = (xp % 500) / 500;
        final streak = streakService.calculateCurrentStreak(state.savedWords);

        return RepaintBoundary(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildChip("🔥 $streak", AppColors.warning),
                    const SizedBox(width: AppSpacing.sm),
                    _buildChip("⭐ $xp XP", AppColors.info),
                    const SizedBox(width: AppSpacing.sm),
                    _buildChip("🏆 Level $level", AppColors.primary),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: CircularProgressIndicator(
                        value: progressToNextLevel,
                        strokeWidth: 10,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          "$level",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Text(
                          "LEVEL",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ).animate().scale(
                  delay: 200.ms,
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  "${(progressToNextLevel * 100).toInt()}% to Level ${level + 1}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}
