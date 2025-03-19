import 'dart:math';
import '../models/problem.dart';

class GameService {
  final Random _random = Random();

  // Generate a random problem based on level
  Problem generateProblem(int level) {
    // Choose a random operation type based on level
    final operations = _getAvailableOperations(level);
    final operationType = operations[_random.nextInt(operations.length)];

    return Problem.generate(operationType, level);
  }

  // Get available operations based on level
  List<OperationType> _getAvailableOperations(int level) {
    if (level < 3) {
      // Level 1-2: Only addition and subtraction
      return [OperationType.addition, OperationType.subtraction];
    } else if (level < 5) {
      // Level 3-4: Add multiplication
      return [OperationType.addition, OperationType.subtraction, OperationType.multiplication];
    } else {
      // Level 5+: All operations
      return OperationType.values;
    }
  }

  // Calculate points for a correct answer
  int calculatePoints(int level, int timeLeft) {
    // Base points for correct answer
    int basePoints = 10 * level;
    
    // Bonus points for quicker answers
    int timeBonus = timeLeft * 2;
    
    return basePoints + timeBonus;
  }

  // Calculate points deduction for wrong answer
  int calculatePenalty(int level) {
    // Penalty increases with level
    return 5 * level;
  }

  // Check if player should level up (every 5 correct answers)
  bool shouldLevelUp(int correctAnswers) {
    return correctAnswers > 0 && correctAnswers % 5 == 0;
  }

  // Calculate time for problem based on level
  int calculateTimeForProblem(int level) {
    // Start with 15 seconds, decrease by level (min 5 seconds)
    return max(15 - (level ~/ 2), 5);
  }
} 