import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/storage_service.dart';
import '../game/game_screen.dart' show startNewGame;
import '../history/history_screen.dart';
import '../levels/level_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      _buildLogo(context),
                      const SizedBox(height: 40),
                      _buildDailyChallenge(context),
                      const SizedBox(height: 30),
                      _buildMainButton(
                        context: context,
                        title: 'Play Game',
                        icon: Icons.play_arrow,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LevelSelectionScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMainButton(
                        context: context,
                        title: 'History',
                        icon: Icons.history,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HistoryScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.calculate,
              size: 60,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Math Fun',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Train your brain with math challenges',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDailyChallenge(BuildContext context) {
    final storageService = context.read<StorageService>();
    final isCompleted = storageService.getDailyChallengeStatus();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium,
                  color: AppTheme.accentColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Daily Challenge',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            isCompleted
                ? _buildCompletedChallenge(context)
                : _buildAvailableChallenge(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedChallenge(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'You\'ve completed today\'s challenge!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableChallenge(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s challenge is waiting for you!',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            startNewGame(context, isDailyChallenge: true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Play Challenge'),
        ),
      ],
    );
  }

  Widget _buildMainButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.transparent,
      child: Text(
        'Math Fun © ${DateTime.now().year}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.textSecondaryColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
} 