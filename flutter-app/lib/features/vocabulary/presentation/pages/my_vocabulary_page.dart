import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/vocabulary_bloc.dart';
import '../bloc/vocabulary_event.dart';
import '../bloc/vocabulary_state.dart';
import '../widgets/add_word_bottom_sheet.dart';
import '../widgets/empty_state.dart';
import '../widgets/skeleton_list.dart';
import '../widgets/word_card.dart';
import '../widgets/sort_options_sheet.dart';
import '../widgets/progress_dashboard.dart';
import '../widgets/discover_tab_view.dart';
import 'stats_page.dart';

class MyVocabularyPage extends StatefulWidget {
  const MyVocabularyPage({super.key});

  @override
  State<MyVocabularyPage> createState() => _MyVocabularyPageState();
}

class _MyVocabularyPageState extends State<MyVocabularyPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<VocabularyBloc>().add(LoadWords());

    _searchController.addListener(() {
      context.read<VocabularyBloc>().add(SearchWords(_searchController.text));
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Opens the modal bottom sheet containing the Add Word form.
  void _openAddWordModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<VocabularyBloc>(),
          child: const AddWordBottomSheet(),
        );
      },
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<VocabularyBloc>(),
        child: const SortOptionsSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("LingoBreeze"),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StatsPage()),
            ),
            icon: const Icon(Icons.insights_rounded),
          ),
          IconButton(
            onPressed: () => _showSortOptions(context),
            icon: const Icon(Icons.sort_rounded),
          ),
          SizedBox(width: AppSpacing.sm),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search words or translations...",
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: AppTheme.textMuted,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: "My Library"),
                    Tab(text: "Discover"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: BlocListener<VocabularyBloc, VocabularyState>(
        listenWhen: (previous, current) => current is VocabularyAddSuccess,
        listener: (context, state) {
          if (state is VocabularyAddSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Word added to your library!"),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppTheme.accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildMyLibraryTab(context, theme),
            const DiscoverTabView(),
          ],
        ),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
            onPressed: () => _openAddWordModal(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text("New Word"),
          ).animate().scale(
            delay: 400.ms,
            duration: 400.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }

  Widget _buildMyLibraryTab(BuildContext context, ThemeData theme) {
    return BlocBuilder<VocabularyBloc, VocabularyState>(
      builder: (context, state) {
        if (state is VocabularyLoading && state.savedWords.isEmpty) {
          return const SingleChildScrollView(child: SkeletonList());
        }

        if (state is VocabularyEmpty && state.searchQuery.isEmpty) {
          return EmptyState(onAddPressed: () => _openAddWordModal(context));
        }

        final words = state.filteredWords;

        return RefreshIndicator(
          onRefresh: () async =>
              context.read<VocabularyBloc>().add(LoadWords()),
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: ProgressDashboard()),
              if (words.isEmpty && state.searchQuery.isNotEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text("No words match your search")),
                ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final word = words[index];
                  return WordCard(
                    word: word,
                    isSaved: true,
                    onFavoriteToggle: (isFav) {
                      context.read<VocabularyBloc>().add(
                        ToggleFavoriteWord(word.id, isFav),
                      );
                    },
                    onDelete: () {
                      context.read<VocabularyBloc>().add(
                        DeleteWordEvent(word.id),
                      );
                    },
                  );
                }, childCount: words.length),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        );
      },
    );
  }
}
