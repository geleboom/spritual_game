import 'dart:math';
import 'package:spiritual_game/features/practice/screens/practice_screen.dart'
    as practice_screen;
import '../models/question.dart';
import '../models/test_question.dart';
import '../../../features/verses/data/verses_data.dart';

class QuestionGenerator {
  static const int MIN_WORD_LENGTH = 4;

  // Generate semantically similar verse references
  static List<String> generateVerseOptions(
      String correctReference, List<String> allReferences) {
    final options = <String>[correctReference];
    final random = Random();

    // Filter references from same book or similar chapter
    final similarReferences = allReferences.where((ref) {
      final correct = _parseReference(correctReference);
      final current = _parseReference(ref);
      return ref != correctReference &&
          (correct.book == current.book ||
              (correct.chapter - current.chapter).abs() <= 2);
    }).toList();

    // Add 3 similar references
    similarReferences.shuffle();
    options.addAll(similarReferences.take(3));
    options.shuffle();

    return options;
  }

  // Generate meaningful blank options
  static Future<Question> generateBlankQuestion(
      String verseText, String language) async {
    // Split verse text into words
    final words = verseText.split(' ');

    // Select words to blank out (every 3rd word)
    final blankedWords = <String>[];
    final blankedText = words.asMap().entries.map((entry) {
      if ((entry.key + 1) % 3 == 0) {
        blankedWords.add(entry.value);
        return '_____';
      }
      return entry.value;
    }).join(' ');

    return Question(
      text:
          (language == 'am' ? 'ባዶ ቦታዎችን ሙሉ:\n\n' : 'Fill in the blanks:\n\n') +
              blankedText,
      options: blankedWords,
      type: QuestionType.fillInBlank,
      correctAnswer: blankedWords.join(' '),
    );
  }

  // Generate meaningful word order segments
  static Future<practice_screen.Question> generateWordOrderQuestion(
      String verseText, String language) async {
    final words = verseText.split(' ');
    final segments = _findMeaningfulSegments(words, language);

    // Select a random segment of 4-6 words
    final selected = segments[Random().nextInt(segments.length)];
    final options = List<String>.from(selected);
    options.shuffle();

    return practice_screen.Question(
      text: language == 'am'
          ? 'ቃላቱን በትክክለኛው ቅደም ተከተል ያስቀምጡ:'
          : 'Put the words in the correct order:',
      type: practice_screen.QuestionType.wordOrder,
      options: options,
      correctAnswer: selected.join(' '),
    );
  }

  // Generate typing question
  static practice_screen.Question generateTypingQuestion(
      String verseText, String language) {
    return practice_screen.Question(
      text: language == 'am' ? 'ጥቅሱን ይጻፉ:' : 'Type the verse:',
      type: practice_screen.QuestionType.typing,
      options: [verseText], // Original text as the only option
      correctAnswer: verseText,
    );
  }

  // Helper methods
  static bool isCommonWord(String word, String language) {
    final commonWords = language == 'am'
        ? ['እና', 'ነው', 'ግን', 'እንዲሁም']
        : ['the', 'and', 'of', 'to', 'in'];
    return commonWords.contains(word.toLowerCase());
  }

  static List<List<String>> _findMeaningfulSegments(
      List<String> words, String language) {
    final segments = <List<String>>[];

    for (int i = 0; i < words.length - 3; i++) {
      final segment = words.sublist(i, min(i + 4, words.length));
      if (segment.any((word) => !isCommonWord(word, language))) {
        segments.add(segment);
      }
    }

    return segments;
  }

  static bool _isSignificantSegment(List<String> segment, String language) {
    final significantWords = segment
        .where((word) =>
            word.length >= MIN_WORD_LENGTH && !isCommonWord(word, language))
        .length;
    return significantWords >= 2;
  }

  static ReferenceInfo _parseReference(String reference) {
    try {
      final parts = reference.split(' ');
      final lastPart = parts.last;

      // Handle different separator formats (: or -)
      final separators = [':', '-'];
      String? separator;
      for (var sep in separators) {
        if (lastPart.contains(sep)) {
          separator = sep;
          break;
        }
      }

      if (separator == null) {
        // If no separator found, treat the last number as both chapter and verse
        final number = int.parse(lastPart);
        return ReferenceInfo(
            book: parts.sublist(0, parts.length - 1).join(' '),
            chapter: number,
            verse: number);
      }

      final chapterVerse = lastPart.split(separator);
      return ReferenceInfo(
          book: parts.sublist(0, parts.length - 1).join(' '),
          chapter: int.parse(chapterVerse[0]),
          verse: int.parse(chapterVerse[1]));
    } catch (e) {
      // Return a default reference if parsing fails
      return ReferenceInfo(book: reference, chapter: 1, verse: 1);
    }
  }

  static practice_screen.Question _fallbackBlankQuestion(List<String> words) {
    // Select a word that's at least 3 characters long
    final eligibleWords = words
        .asMap()
        .entries
        .where((entry) => entry.value.length >= 3)
        .toList();

    if (eligibleWords.isEmpty) {
      // If no eligible words found, use the first word as fallback
      return practice_screen.Question(
        text: words.join(' ').replaceFirst(words[0], '_____'),
        type: practice_screen.QuestionType.fillInBlank,
        options: [words[0]],
        correctAnswer: words[0],
      );
    }

    final selected = eligibleWords[Random().nextInt(eligibleWords.length)];
    final blankIndex = selected.key;

    // Generate options including the correct word
    final options = [words[blankIndex]];
    final otherWords =
        words.where((w) => w != words[blankIndex] && w.length >= 3).toList();

    otherWords.shuffle();
    options.addAll(otherWords.take(3));
    options.shuffle();

    return practice_screen.Question(
      text: words.join(' ').replaceAll(words[blankIndex], '_____'),
      type: practice_screen.QuestionType.fillInBlank,
      options: options,
      correctAnswer: words[blankIndex],
    );
  }

  static List<TestQuestion> generateTestQuestions(
    String verseText,
    String reference,
    String language,
  ) {
    final questions = <TestQuestion>[];
    final words = verseText.split(' ');

    // Question 1: Word Order Question
    final segments = _findMeaningfulSegments(words, language);
    if (segments.isNotEmpty) {
      final selectedSegment = segments[Random().nextInt(segments.length)];
      final options = List<String>.from([selectedSegment.join(' ')]);

      // Generate 3 wrong arrangements
      for (int i = 0; i < 3; i++) {
        final shuffled = List<String>.from(selectedSegment);
        shuffled.shuffle();
        options.add(shuffled.join(' '));
      }

      questions.add(TestQuestion(
        question: language == 'am'
            ? 'የሚከተሉት ቃላት ትክክለኛ ቅደም ተከተል የትኛው ነው?'
            : 'Which is the correct order of these words?',
        options: options,
        correctAnswerIndex: 0,
      ));
    }

    // Question 2: Verse Reference Question
    final allReferences =
        versesData.values.map((verse) => verse.reference).toList();
    final referenceOptions = generateVerseOptions(reference, allReferences);
    questions.add(TestQuestion(
      question: language == 'am'
          ? 'የዚህ ጥቅስ ትክክለኛው የመጽሐፍ ቅዱስ ምዕራፍ የትኛው ነው?'
          : 'What is the correct reference for this verse?',
      options: referenceOptions,
      correctAnswerIndex: referenceOptions.indexOf(reference),
    ));

    // Question 3: Fill in the Blank
    final significantWords = words
        .where((word) =>
            word.length >= MIN_WORD_LENGTH && !isCommonWord(word, language))
        .toList();

    if (significantWords.isNotEmpty) {
      final selectedWord =
          significantWords[Random().nextInt(significantWords.length)];
      final blankText = verseText.replaceFirst(selectedWord, '_____');

      // Generate options including the correct word
      final options = [selectedWord];
      final otherWords =
          significantWords.where((w) => w != selectedWord).toList();
      otherWords.shuffle();
      options.addAll(otherWords.take(3));
      options.shuffle();

      questions.add(TestQuestion(
        question: language == 'am'
            ? 'ባዶ ቦታውን የሚሞላው ቃል የትኛው ነው?\n\n$blankText'
            : 'Which word fills in the blank?\n\n$blankText',
        options: options,
        correctAnswerIndex: options.indexOf(selectedWord),
      ));
    }

    return questions;
  }

  static List<String> generateMeaningOptions(
      String verseText, String language) {
    final words = verseText.split(' ');
    final significantWords = words
        .where((word) =>
            word.length >= MIN_WORD_LENGTH && !isCommonWord(word, language))
        .toList();

    if (significantWords.isEmpty) return [verseText];

    // Select a random significant word
    final selectedWord =
        significantWords[Random().nextInt(significantWords.length)];

    // Generate options including the correct meaning
    return [
      selectedWord,
      // Add 3 different words as distractors
      ...words
          .where((w) => w != selectedWord && w.length >= MIN_WORD_LENGTH)
          .take(3)
          .toList(),
    ]..shuffle();
  }

  static String getCorrectMeaning(String verseText, String language) {
    final words = verseText.split(' ');
    final significantWords = words
        .where((word) =>
            word.length >= MIN_WORD_LENGTH && !isCommonWord(word, language))
        .toList();

    return significantWords.isNotEmpty ? significantWords.first : verseText;
  }

  static List<String> generateContextOptions(
      String verseText, String reference, String language) {
    final correctOption = verseText;
    final options = <String>[correctOption];

    // Generate 3 different context options
    for (int i = 0; i < 3; i++) {
      options.add(_generateAlternativeContext(verseText, language));
    }

    options.shuffle();
    return options;
  }

  static String _generateAlternativeContext(String verseText, String language) {
    // Generate a modified version of the verse text as a distractor
    final words = verseText.split(' ');
    words.shuffle();
    return words.take(words.length ~/ 2).join(' ');
  }

  static Future<List<String>> generateBlankOptions(
      String verseText, String language) async {
    final question = await generateBlankQuestion(verseText, language);
    return question.options;
  }

  static Future<String> getCorrectBlankAnswer(
      String verseText, String language) async {
    final question = await generateBlankQuestion(verseText, language);
    return question.correctAnswer;
  }

  static List<String> generateWordOrderOptions(
      String verseText, String language) {
    final words = verseText.split(' ');
    final segments = _findMeaningfulSegments(words, language);

    if (segments.isEmpty) return [verseText];

    final selectedSegment = segments[Random().nextInt(segments.length)];
    final options = List<String>.from(selectedSegment);
    options.shuffle();

    return options;
  }
}

class ReferenceInfo {
  final String book;
  final int chapter;
  final int verse;

  ReferenceInfo(
      {required this.book, required this.chapter, required this.verse});
}
