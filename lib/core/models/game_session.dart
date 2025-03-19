import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class GameSession extends Equatable {
  final String id;
  final DateTime date;
  final int score;
  final int level;
  final int correctAnswers;
  final int totalProblems;
  final Duration duration;

  const GameSession({
    required this.id,
    required this.date,
    required this.score,
    required this.level,
    required this.correctAnswers,
    required this.totalProblems,
    required this.duration,
  });

  factory GameSession.create({
    required int score,
    required int level,
    required int correctAnswers,
    required int totalProblems,
    required Duration duration,
  }) {
    return GameSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      score: score,
      level: level,
      correctAnswers: correctAnswers,
      totalProblems: totalProblems,
      duration: duration,
    );
  }

  // Convert to Map for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'score': score,
      'level': level,
      'correctAnswers': correctAnswers,
      'totalProblems': totalProblems,
      'duration': duration.inSeconds,
    };
  }

  // Create from stored Map
  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['id'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      score: json['score'],
      level: json['level'],
      correctAnswers: json['correctAnswers'],
      totalProblems: json['totalProblems'],
      duration: Duration(seconds: json['duration']),
    );
  }

  // Formatted date string
  String get formattedDate {
    final formatter = DateFormat('MMM dd, yyyy - HH:mm');
    return formatter.format(date);
  }

  // Formatted duration string
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Accuracy percentage
  double get accuracy {
    if (totalProblems == 0) return 0;
    return (correctAnswers / totalProblems) * 100;
  }

  String get formattedAccuracy {
    return '${accuracy.toStringAsFixed(1)}%';
  }

  @override
  List<Object?> get props => [id, date, score, level, correctAnswers, totalProblems, duration];
} 