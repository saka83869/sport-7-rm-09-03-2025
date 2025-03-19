import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GameStats extends StatelessWidget {
  final int score;
  final int level;
  final int correctAnswers;
  final int totalProblems;
  final bool compact;

  const GameStats({
    super.key,
    required this.score,
    required this.level,
    required this.correctAnswers,
    required this.totalProblems,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactStats(context);
    }
    return _buildFullStats(context);
  }

  Widget _buildFullStats(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(context, 'Score', score.toString()),
            _buildStatItem(context, 'Level', level.toString()),
            _buildStatItem(
              context, 
              'Accuracy', 
              totalProblems > 0 
                ? '${((correctAnswers / totalProblems) * 100).toStringAsFixed(0)}%' 
                : '0%'
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStats(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCompactStatItem(context, 'Score', score.toString()),
        const SizedBox(width: 24),
        _buildCompactStatItem(context, 'Level', level.toString()),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactStatItem(BuildContext context, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
} 