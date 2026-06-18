import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/vocabulary_bloc.dart';
import '../bloc/vocabulary_event.dart';
import '../bloc/vocabulary_state.dart';
import 'word_card.dart';
import 'skeleton_list.dart';

class DiscoverTabView extends StatelessWidget {
  const DiscoverTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VocabularyBloc, VocabularyState>(
      builder: (context, state) {
        if (state is VocabularyLoading && state.apiWords.isEmpty) {
          return const SingleChildScrollView(child: SkeletonList());
        }

        final apiWords = state.apiWords;
        if (apiWords.isEmpty) return _buildErrorState(context);

        final dailyWord = apiWords.first;
        final theme = _getDailyTheme();

        return RefreshIndicator(
          onRefresh: () async =>
              context.read<VocabularyBloc>().add(RefreshWords()),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildThemeBanner(theme)),
              SliverToBoxAdapter(child: _buildSectionHeader("Word of the Day")),
              SliverToBoxAdapter(
                child: _buildDailyHero(context, dailyWord, state),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.lg)),
              SliverToBoxAdapter(
                child: _buildSectionHeader("Themed Collection: ${theme.name}"),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final word = apiWords[index + 1];
                  final isSaved = state.savedWords.any(
                    (s) => s.word == word.word,
                  );
                  return WordCard(
                    word: word,
                    isSaved: isSaved,
                    onSave: isSaved
                        ? null
                        : () => context.read<VocabularyBloc>().add(
                            AddWordEvent(
                              word: word.word,
                              meaning: word.meaning,
                              translation: word.translation,
                            ),
                          ),
                  );
                }, childCount: apiWords.length - 1),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildThemeBanner(_DailyTheme theme) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: theme.colors),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  theme.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  theme.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Icon(
            theme.icon,
            color: Colors.white.withValues(alpha: 0.5),
            size: 64,
          ),
        ],
      ),
    );
  }

  _DailyTheme _getDailyTheme() {
    final now = DateTime.now();
    if (now.month == 2 && now.day == 14) {
      return _DailyTheme("Valentine's Day", "Learn the language of love.", [
        Color(0xFFF43F5E),
        Color(0xFFFB7185),
      ], Icons.favorite);
    }
    if (now.month == 12) {
      return _DailyTheme(
        "Winter Wonderland",
        "Vocabulary for the festive season.",
        [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
        Icons.ac_unit,
      );
    }
    return _DailyTheme("Daily Growth", "Expand your horizons today.", [
      Color(0xFF6366F1),
      Color(0xFF818CF8),
    ], Icons.auto_graph);
  }

  Widget _buildDailyHero(
    BuildContext context,
    dynamic word,
    VocabularyState state,
  ) {
    final isSaved = state.savedWords.any((s) => s.word == word.word);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            word.word.toUpperCase(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          Text(
            word.translation,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            word.meaning,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: isSaved
                ? null
                : () => context.read<VocabularyBloc>().add(
                    AddWordEvent(
                      word: word.word,
                      meaning: word.meaning,
                      translation: word.translation,
                    ),
                  ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
            ),
            child: Text(isSaved ? "Saved to Library" : "Learn Word"),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              "Connection Issue",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              "We couldn't load new words. Check your connection or try again.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => context.read<VocabularyBloc>().add(LoadWords()),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Retry Now"),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyTheme {
  final String name;
  final String description;
  final List<Color> colors;
  final IconData icon;
  _DailyTheme(this.name, this.description, this.colors, this.icon);
}
