import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/vocabulary_word.dart';
import '../bloc/vocabulary_bloc.dart';
import '../bloc/vocabulary_state.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Learning Insights")),
      body: BlocBuilder<VocabularyBloc, VocabularyState>(
        builder: (context, state) {
          final words = state.savedWords;
          final mastered = words.where((w) => w.status == LearningStatus.mastered).length;
          final learning = words.where((w) => w.status == LearningStatus.learning).length;
          final notStarted = words.where((w) => w.status == LearningStatus.notStarted).length;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _buildChartSection("Mastery Distribution", _buildPieChart(mastered, learning, notStarted)),
              const SizedBox(height: AppSpacing.lg),
              _buildChartSection("Weekly Activity", _buildBarChart()),
              const SizedBox(height: AppSpacing.lg),
              _buildDetailedStats(words),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChartSection(String title, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildPieChart(int mastered, int learning, int notStarted) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(value: mastered.toDouble(), color: AppColors.success, title: "Mastered", radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          PieChartSectionData(value: learning.toDouble(), color: AppColors.warning, title: "Learning", radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          PieChartSectionData(value: notStarted.toDouble(), color: AppColors.info, title: "New", radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 5, color: AppColors.primary, width: 16, borderRadius: BorderRadius.circular(4))]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 8, color: AppColors.primary, width: 16, borderRadius: BorderRadius.circular(4))]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 3, color: AppColors.primary, width: 16, borderRadius: BorderRadius.circular(4))]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 10, color: AppColors.primary, width: 16, borderRadius: BorderRadius.circular(4))]),
          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 7, color: AppColors.primary, width: 16, borderRadius: BorderRadius.circular(4))]),
        ],
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildDetailedStats(dynamic words) {
    return Row(
      children: [
        _buildStatBox("Total Words", words.length.toString(), Icons.book),
        const SizedBox(width: AppSpacing.md),
        _buildStatBox("Avg Accuracy", "84%", Icons.percent),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: AppSpacing.sm),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
