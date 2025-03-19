import 'package:equatable/equatable.dart';

enum OperationType {
  addition,
  subtraction,
  multiplication,
  division
}

class Problem extends Equatable {
  final int operand1;
  final int operand2;
  final OperationType operation;
  final int correctAnswer;
  final String question;

  const Problem({
    required this.operand1,
    required this.operand2,
    required this.operation,
    required this.correctAnswer,
    required this.question,
  });

  factory Problem.generate(OperationType operation, int difficulty) {
    int op1, op2, answer;
    String questionText;

    switch (operation) {
      case OperationType.addition:
        op1 = _generateRandomNumber(difficulty);
        op2 = _generateRandomNumber(difficulty);
        answer = op1 + op2;
        questionText = "$op1 + $op2 = ?";
        break;
      case OperationType.subtraction:
        op1 = _generateRandomNumber(difficulty);
        op2 = _generateRandomNumber(difficulty ~/ 2);
        // Ensure positive answer for younger players
        if (op2 > op1) {
          final temp = op1;
          op1 = op2;
          op2 = temp;
        }
        answer = op1 - op2;
        questionText = "$op1 - $op2 = ?";
        break;
      case OperationType.multiplication:
        // Adjust difficulty for multiplication
        op1 = _generateRandomNumber(difficulty ~/ 2);
        op2 = _generateRandomNumber(difficulty ~/ 2);
        answer = op1 * op2;
        questionText = "$op1 × $op2 = ?";
        break;
      case OperationType.division:
        // Generate division problems with whole number answers
        op2 = _generateRandomNumber(difficulty ~/ 2, min: 1); // Ensure non-zero divisor
        answer = _generateRandomNumber(difficulty ~/ 2, min: 1);
        op1 = op2 * answer; // This ensures clean division
        questionText = "$op1 ÷ $op2 = ?";
        break;
    }

    return Problem(
      operand1: op1,
      operand2: op2,
      operation: operation,
      correctAnswer: answer,
      question: questionText,
    );
  }

  static int _generateRandomNumber(int difficulty, {int min = 0}) {
    final maxValue = difficulty <= 1 ? 10 : (difficulty * 10);
    return min + (DateTime.now().millisecondsSinceEpoch % (maxValue - min + 1));
  }

  bool checkAnswer(int userAnswer) {
    return userAnswer == correctAnswer;
  }

  @override
  List<Object?> get props => [operand1, operand2, operation, correctAnswer, question];
} 