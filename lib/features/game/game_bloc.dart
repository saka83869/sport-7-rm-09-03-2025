import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/models/game_state.dart';
import '../../core/models/problem.dart';
import '../../core/models/game_session.dart';
import '../../core/utils/game_service.dart';
import '../../core/utils/storage_service.dart';
import '../levels/level_selection_screen.dart';

// Events
abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class GameStarted extends GameEvent {
  final GameDifficulty? difficulty;

  const GameStarted({this.difficulty});
  
  @override
  List<Object?> get props => [difficulty];
}

class GamePaused extends GameEvent {
  const GamePaused();
}

class GameResumed extends GameEvent {
  const GameResumed();
}

class GameTimerTicked extends GameEvent {
  final int timeLeft;

  const GameTimerTicked(this.timeLeft);

  @override
  List<Object?> get props => [timeLeft];
}

class AnswerSubmitted extends GameEvent {
  final int answer;

  const AnswerSubmitted(this.answer);

  @override
  List<Object?> get props => [answer];
}

class NextProblemRequested extends GameEvent {
  const NextProblemRequested();
}

class GameEnded extends GameEvent {
  const GameEnded();
}

// Bloc
class GameBloc extends Bloc<GameEvent, GameState> {
  final GameService _gameService;
  final StorageService _storageService;
  Timer? _timer;

  GameBloc({
    required GameService gameService, 
    required StorageService storageService,
  }) : _gameService = gameService,
       _storageService = storageService,
       super(const GameState()) {
    on<GameStarted>(_onGameStarted);
    on<GamePaused>(_onGamePaused);
    on<GameResumed>(_onGameResumed);
    on<GameTimerTicked>(_onGameTimerTicked);
    on<AnswerSubmitted>(_onAnswerSubmitted);
    on<NextProblemRequested>(_onNextProblemRequested);
    on<GameEnded>(_onGameEnded);
  }

  void _onGameStarted(GameStarted event, Emitter<GameState> emit) {
    // Cancel any existing timer
    _timer?.cancel();

    // Set initial level based on difficulty
    int initialLevel = 1;
    int timeModifier = 0;
    
    if (event.difficulty != null) {
      switch (event.difficulty!) {
        case GameDifficulty.easy:
          initialLevel = 1;
          timeModifier = 3; // More time for easy level
          break;
        case GameDifficulty.medium:
          initialLevel = 3;
          timeModifier = 0; // Default time for medium
          break;
        case GameDifficulty.hard:
          initialLevel = 5;
          timeModifier = -2; // Less time for hard level
          break;
      }
    }

    // Generate first problem
    final problem = _gameService.generateProblem(initialLevel);
    final timePerProblem = _gameService.calculateTimeForProblem(initialLevel) + timeModifier;

    // Start with fresh state
    emit(GameState(
      status: GameStatus.running,
      level: initialLevel,
      score: 0,
      correctAnswers: 0,
      totalProblems: 0,
      currentProblem: problem,
      timeLeft: timePerProblem,
      timeModifier: timeModifier,
      startTime: DateTime.now(),
    ));

    // Start timer
    _startTimer(timePerProblem);
  }

  void _onGamePaused(GamePaused event, Emitter<GameState> emit) {
    _timer?.cancel();
    emit(state.copyWith(status: GameStatus.paused));
  }

  void _onGameResumed(GameResumed event, Emitter<GameState> emit) {
    emit(state.copyWith(status: GameStatus.running));
    _startTimer(state.timeLeft);
  }

  void _onGameTimerTicked(GameTimerTicked event, Emitter<GameState> emit) {
    if (state.status != GameStatus.running) return;

    if (event.timeLeft > 0) {
      emit(state.copyWith(timeLeft: event.timeLeft));
    } else {
      // Time's up - move to next problem
      _timer?.cancel();
      add(const NextProblemRequested());
    }
  }

  void _onAnswerSubmitted(AnswerSubmitted event, Emitter<GameState> emit) {
    _timer?.cancel();
    
    final isCorrect = state.currentProblem?.checkAnswer(event.answer) ?? false;
    
    int newScore = state.score;
    int correctAnswers = state.correctAnswers;
    int level = state.level;
    
    if (isCorrect) {
      // Add points for correct answer
      final points = _gameService.calculatePoints(state.level, state.timeLeft);
      newScore += points;
      correctAnswers += 1;
      
      // Check if should level up
      if (_gameService.shouldLevelUp(correctAnswers)) {
        level += 1;
      }
    } else {
      // Subtract points for wrong answer
      final penalty = _gameService.calculatePenalty(state.level);
      newScore = (newScore - penalty).clamp(0, double.infinity).toInt();
    }

    // Emit updated state with results and a short delay before next problem
    emit(state.copyWith(
      score: newScore,
      correctAnswers: correctAnswers,
      level: level,
      totalProblems: state.totalProblems + 1,
    ));

    // Use a Timer instead of Future.delayed for safer cancellation
    _timer = Timer(const Duration(seconds: 2), () {
      add(const NextProblemRequested());
    });
  }

  void _onNextProblemRequested(NextProblemRequested event, Emitter<GameState> emit) {
    // Generate next problem
    final problem = _gameService.generateProblem(state.level);
    final timePerProblem = _gameService.calculateTimeForProblem(state.level) + state.timeModifier;
    
    emit(state.copyWith(
      currentProblem: problem,
      timeLeft: timePerProblem,
    ));
    
    // Start timer for next problem
    _startTimer(timePerProblem);
  }

  void _onGameEnded(GameEnded event, Emitter<GameState> emit) {
    _timer?.cancel();
    
    // Save game session
    final gameSession = GameSession.create(
      score: state.score,
      level: state.level,
      correctAnswers: state.correctAnswers,
      totalProblems: state.totalProblems,
      duration: state.duration,
    );
    _storageService.saveGameSession(gameSession);
    
    // Update state
    emit(state.copyWith(
      status: GameStatus.completed,
      endTime: DateTime.now(),
    ));
  }

  void _startTimer(int seconds) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(GameTimerTicked(seconds - timer.tick));
      if (timer.tick >= seconds) {
        timer.cancel();
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
} 