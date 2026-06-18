import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/vocabulary_bloc.dart';
import '../bloc/vocabulary_event.dart';
import '../bloc/vocabulary_state.dart';

class SortOptionsSheet extends StatelessWidget {
  const SortOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VocabularyBloc, VocabularyState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Sort Vocabulary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildOption(
                context,
                "Newest First",
                Icons.calendar_today_rounded,
                VocabularySortType.newest,
                state.sortType == VocabularySortType.newest,
              ),
              _buildOption(
                context,
                "Oldest First",
                Icons.history_rounded,
                VocabularySortType.oldest,
                state.sortType == VocabularySortType.oldest,
              ),
              _buildOption(
                context,
                "Alphabetical (A-Z)",
                Icons.sort_by_alpha_rounded,
                VocabularySortType.alphabetical,
                state.sortType == VocabularySortType.alphabetical,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(
    BuildContext context,
    String title,
    IconData icon,
    VocabularySortType type,
    bool isSelected,
  ) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.indigo : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.indigo : Colors.black87,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.indigo)
          : null,
      onTap: () {
        context.read<VocabularyBloc>().add(SortWords(type));
        Navigator.pop(context);
      },
    );
  }
}
