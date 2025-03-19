import 'package:equatable/equatable.dart';
import 'problem.dart';

enum GameStatus {
  notStarted,
  running,
  paused,
  completed
}

class GameState extends Equatable {
  final GameStatus status;
  final int level;
  final int score;
  final int correctAnswers;
  final int totalProblems;
  final Problem? currentProblem;
  final int timeLeft; // in seconds
  final int timeModifier; // adjustment to time based on difficulty
  final DateTime? startTime;
  final DateTime? endTime;

  const GameState({
    this.status = GameStatus.notStarted,
    this.level = 1,
    this.score = 0,
    this.correctAnswers = 0,
    this.totalProblems = 0,
    this.currentProblem,
    this.timeLeft = 15, // Default time per problem
    this.timeModifier = 0,
    this.startTime,
    this.endTime,
  });

  GameState copyWith({
    GameStatus? status,
    int? level,
    int? score,
    int? correctAnswers,
    int? totalProblems,
    Problem? currentProblem,
    int? timeLeft,
    int? timeModifier,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return GameState(
      status: status ?? this.status,
      level: level ?? this.level,
      score: score ?? this.score,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalProblems: totalProblems ?? this.totalProblems,
      currentProblem: currentProblem ?? this.currentProblem,
      timeLeft: timeLeft ?? this.timeLeft,
      timeModifier: timeModifier ?? this.timeModifier,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  Duration get duration {
    if (startTime == null) {
      return Duration.zero;
    }
    
    final end = endTime ?? DateTime.now();
    return end.difference(startTime!);
  }

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  int get timePerProblem {
    // Reduce time per problem as level increases, adjusted by difficulty modifier
    return (15 - (level ~/ 2) + timeModifier).clamp(3, 20);
  }

  @override
  List<Object?> get props => [
    status, 
    level, 
    score, 
    correctAnswers, 
    totalProblems, 
    currentProblem, 
    timeLeft, 
    timeModifier,
    startTime, 
    endTime
  ];
} 