import 'package:flutter/material.dart';
import '../models/game_session.dart';
import '../theme/app_theme.dart';

class HistoryItem extends StatelessWidget {
  final GameSession session;

  const HistoryItem({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  session.formattedDate,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                Text(
                  'Duration: ${session.formattedDuration}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildDataPoint(context, 'Score', session.score.toString()),
                _buildDataPoint(context, 'Level', session.level.toString()),
                _buildDataPoint(context, 'Accuracy', session.formattedAccuracy),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildDataPoint(
                  context,
                  'Problems',
                  '${session.correctAnswers}/${session.totalProblems}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataPoint(BuildContext context, String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
} 