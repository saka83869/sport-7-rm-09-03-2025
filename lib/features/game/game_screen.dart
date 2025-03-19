import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/models/game_state.dart';
import '../../core/widgets/countdown_timer.dart';
import '../../core/widgets/game_stats.dart';
import '../../core/widgets/problem_card.dart';
import '../../core/utils/game_service.dart';
import '../../core/utils/storage_service.dart';
import '../levels/level_selection_screen.dart';
import 'game_bloc.dart';
import 'game_result_screen.dart';

// Expose a way to create a new game
void startNewGame(BuildContext context, {bool isDailyChallenge = false}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GameScreen(isDailyChallenge: isDailyChallenge),
    ),
  );
}

class GameScreen extends StatefulWidget {
  final bool isDailyChallenge;
  final GameDifficulty? difficulty;

  const GameScreen({
    super.key, 
    this.isDailyChallenge = false,
    this.difficulty,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final TextEditingController _answerController = TextEditingController();
  late final GameBloc _gameBloc;
  bool _showFeedback = false;
  bool _isAnswerCorrect = false;

  @override
  void initState() {
    super.initState();
    final gameService = GameService();
    final storageService = RepositoryProvider.of<StorageService>(context);
    
    _gameBloc = GameBloc(
      gameService: gameService,
      storageService: storageService,
    );
    
    // Start the game with the selected difficulty
    if (widget.difficulty != null) {
      _gameBloc.add(GameStarted(difficulty: widget.difficulty!));
    } else {
      _gameBloc.add(const GameStarted());
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    _gameBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _gameBloc,
      child: BlocConsumer<GameBloc, GameState>(
        listener: (context, state) {
          if (state.status == GameStatus.completed) {
            // When the game is completed, navigate to the result screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => GameResultScreen(gameState: state),
              ),
            );
            
            // Mark daily challenge as completed if applicable
            if (widget.isDailyChallenge) {
              final storageService = context.read<StorageService>();
              storageService.completeDailyChallenge();
            }
          }
        },
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () async {
              // Ask for confirmation before leaving the game
              if (state.status != GameStatus.completed) {
                final shouldPop = await _showExitConfirmationDialog(context);
                if (shouldPop) {
                  _gameBloc.add(const GameEnded());
                }
                return shouldPop;
              }
              return true;
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(widget.isDailyChallenge ? 'Daily Challenge' : 'Math Fun'),
                actions: [
                  // Pause/Resume button
                  if (state.status != GameStatus.completed)
                    IconButton(
                      icon: Icon(
                        state.status == GameStatus.paused
                            ? Icons.play_arrow
                            : Icons.pause,
                      ),
                      onPressed: () {
                        if (state.status == GameStatus.paused) {
                          _gameBloc.add(const GameResumed());
                        } else {
                          _gameBloc.add(const GamePaused());
                        }
                      },
                    ),
                ],
              ),
              body: state.status == GameStatus.paused
                  ? _buildPausedScreen(context)
                  : _buildGameContent(context, state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameContent(BuildContext context, GameState state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Game stats
            GameStats(
              score: state.score,
              level: state.level,
              correctAnswers: state.correctAnswers,
              totalProblems: state.totalProblems,
            ),
            const SizedBox(height: 16),
            
            // Timer
            CountdownTimer(
              timeLeft: state.timeLeft,
              totalTime: state.timePerProblem,
            ),
            const SizedBox(height: 24),
            
            // Problem card
            if (state.currentProblem != null)
              ProblemCard(
                problem: state.currentProblem!,
                showResult: _showFeedback,
                isCorrect: _isAnswerCorrect,
              ),
            
            const SizedBox(height: 24),
            
            // Answer input
            if (!_showFeedback) _buildAnswerInput(context),
            
            const Spacer(),
            
            // End game button
            ElevatedButton(
              onPressed: () {
                _gameBloc.add(const GameEnded());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('End Game'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerInput(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _answerController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24),
          decoration: InputDecoration(
            hintText: 'Enter your answer',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSubmitted: (_) => _submitAnswer(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitAnswer,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Submit Answer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPausedScreen(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.pause_circle_filled,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          Text(
            'Game Paused',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              _gameBloc.add(const GameResumed());
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
            child: const Text(
              'Resume Game',
              style: TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              _gameBloc.add(const GameEnded());
            },
            child: const Text('End Game'),
          ),
        ],
      ),
    );
  }

  void _submitAnswer() {
    final answerText = _answerController.text.trim();
    if (answerText.isEmpty) return;
    
    try {
      final answer = int.parse(answerText);
      final currentProblem = _gameBloc.state.currentProblem;
      
      if (currentProblem != null) {
        setState(() {
          _showFeedback = true;
          _isAnswerCorrect = currentProblem.checkAnswer(answer);
        });
        
        _gameBloc.add(AnswerSubmitted(answer));
        _answerController.clear();
        
        // Hide feedback after delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showFeedback = false;
            });
          }
        });
      }
    } catch (e) {
      // Show error for non-numeric input
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Game?'),
        content: const Text(
          'Are you sure you want to end the game? Your progress will be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('End Game'),
          ),
        ],
      ),
    ) ?? false;
  }
} 