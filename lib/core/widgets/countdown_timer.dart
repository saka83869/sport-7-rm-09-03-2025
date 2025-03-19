import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CountdownTimer extends StatelessWidget {
  final int timeLeft;
  final int totalTime;

  const CountdownTimer({
    super.key,
    required this.timeLeft,
    required this.totalTime,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress (inverted since we're counting down)
    final progress = timeLeft / totalTime;
    
    // Determine color based on time left
    final Color progressColor = _getProgressColor(progress);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$timeLeft',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: progressColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 160,
          height: 8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress > 0.6) {
      return Colors.green;
    } else if (progress > 0.3) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
} 