class TestQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String? explanation;

  const TestQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
  });

  bool isCorrect(int selectedIndex) => selectedIndex == correctAnswerIndex;
}