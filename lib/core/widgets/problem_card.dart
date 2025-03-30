import 'package:flutter/material.dart';
import '../models/problem.dart';
import '../theme/app_theme.dart';

class ProblemCard extends StatelessWidget {
  final Problem problem;
  final bool showResult;
  final bool isCorrect;

  const ProblemCard({
    super.key,
    required this.problem,
    this.showResult = false,
    this.isCorrect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _getCardColor(),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Problem',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                problem.question,
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
            if (showResult) ...[
              const SizedBox(height: 24),
              _buildResultSection(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection(BuildContext context) {
    final resultText = isCorrect ? 'Correct!' : 'Incorrect!';
    final resultIcon = isCorrect ? Icons.check_circle : Icons.cancel;
    final resultColor = isCorrect ? Colors.green : Colors.red;
    final answerText =
        isCorrect ? '' : 'Correct answer: ${problem.correctAnswer}';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(resultIcon, color: resultColor, size: 28),
            const SizedBox(width: 8),
            Text(
              resultText,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: resultColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (!isCorrect) ...[
          const SizedBox(height: 8),
          Text(
            answerText,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ],
    );
  }

  Color _getCardColor() {
    if (!showResult) return AppTheme.cardColor;
    return isCorrect
        ? Colors.green.withOpacity(0.1)
        : Colors.red.withOpacity(0.1);
  }
}
