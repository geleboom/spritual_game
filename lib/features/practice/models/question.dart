enum QuestionType {
  fillInBlank,
  wordOrder,
  typing,
  multipleChoice
}

class Question {
  final String text;
  final QuestionType type;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.text,
    required this.type,
    required this.options,
    required this.correctAnswer,
  });
}