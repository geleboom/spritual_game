import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiritual_game/features/verses/models/verse.dart';
import 'package:spiritual_game/features/settings/providers/settings_provider.dart';
import 'package:spiritual_game/features/progress/services/progress_service.dart';
import 'package:spiritual_game/features/profile/models/user_profile.dart';
import 'dart:convert';

class TypeModeScreen extends StatefulWidget {
  final Verse verse;
  final SettingsProvider settings;

  const TypeModeScreen({
    Key? key,
    required this.verse,
    required this.settings,
  }) : super(key: key);

  @override
  State<TypeModeScreen> createState() => _TypeModeScreenState();
}

class _TypeModeScreenState extends State<TypeModeScreen> {
  final TextEditingController _controller = TextEditingController();
  double _accuracy = 0.0;
  List<String> _suggestions = [];
  bool _showAnswer = false;
  final List<double> _accuracyHistory = [];
  bool _isUpdating = false;
  bool _isComplete = false;
  int _totalAttempts = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (_isUpdating) return;
    _isUpdating = true;

    // Calculate accuracy immediately
    _calculateAccuracy();

    // Update suggestions
    _updateSuggestions();

    _isUpdating = false;
  }

  void _updateSuggestions() {
    final text = widget.settings.language == 'am'
        ? widget.verse.verseText
        : widget.verse.translation;

    final words = text.split(' ');
    final currentWord = _controller.text.split(' ').last.toLowerCase();

    print('Current word being typed: $currentWord');
    print('Available words: $words');

    if (currentWord.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    final newSuggestions = words
        .where((word) => word.toLowerCase().startsWith(currentWord))
        .take(3)
        .toList();

    print('Found suggestions: $newSuggestions');

    if (!mounted) return;

    setState(() {
      _suggestions = newSuggestions;
    });
  }

  void _insertSuggestion(String word) {
    print('Inserting suggestion: $word');

    final currentWords = _controller.text.split(' ');
    currentWords.removeLast(); // Remove the partial word
    currentWords.add(word); // Add the suggested word

    _controller.text = '${currentWords.join(' ')} ';
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );

    print('Updated text: ${_controller.text}');
  }

  void _calculateAccuracy() {
    final text = widget.settings.language == 'am'
        ? widget.verse.verseText
        : widget.verse.translation;
    final userText = _controller.text.trim();

    if (text.isEmpty || userText.isEmpty) {
      if (!mounted) return;
      setState(() {
        _accuracy = 0.0;
        if (_accuracyHistory.isNotEmpty) {
          _accuracyHistory.removeLast();
        }
      });
      return;
    }

    final textWords = text.toLowerCase().split(' ');
    final userWords = userText.toLowerCase().split(' ');

    print('Text words: $textWords');
    print('User words: $userWords');

    int correctWords = 0;
    int totalWords = textWords.length; // Use total expected words

    // Compare each word
    for (int i = 0; i < textWords.length && i < userWords.length; i++) {
      if (userWords[i].isNotEmpty && textWords[i] == userWords[i]) {
        correctWords++;
        print('Correct word: ${userWords[i]}');
      } else {
        print('Incorrect word: ${userWords[i]} (expected: ${textWords[i]})');
      }
    }

    // Calculate accuracy based on total expected words
    final newAccuracy = (correctWords / totalWords) * 100;

    print(
        'Accuracy calculation: $correctWords correct out of $totalWords words = $newAccuracy%');

    if (!mounted) return;

    setState(() {
      _accuracy = newAccuracy;

      // Update accuracy history
      if (_accuracyHistory.isEmpty) {
        _accuracyHistory.add(newAccuracy);
        _totalAttempts++;
      } else {
        // Update the last accuracy value instead of adding a new one
        _accuracyHistory[_accuracyHistory.length - 1] = newAccuracy;
      }
    });

    // Only complete if all words are typed and accuracy is high enough
    if (newAccuracy >= 95 &&
        userWords.length >= textWords.length &&
        !_isComplete) {
      _isComplete = true;
      print('Verse completed! Saving progress...');
      _saveProgress();
    }
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressService = ProgressService(prefs);

      print('Saving type mode progress for verse ${widget.verse.id}');
      print('Current accuracy: $_accuracy');

      // Save progress with mode (convert accuracy to true/false result)
      await progressService.updateProgress(widget.verse.id, [_accuracy >= 95],
          mode: 'type');

      // Update verse progress
      widget.verse.progress = _accuracy.round();

      // Update user profile with completed verse
      final userProfileJson = prefs.getString('user_profile');
      if (userProfileJson != null) {
        final userProfile = UserProfile.fromJson(jsonDecode(userProfileJson));
        if (!userProfile.completedVerses.contains(widget.verse.id)) {
          userProfile.completedVerses.add(widget.verse.id);
          await prefs.setString(
              'user_profile', jsonEncode(userProfile.toJson()));
          print(
              'Added verse ${widget.verse.id} to completed verses in profile');
        }
      }

      // Show completion message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.settings.language == 'am'
                ? 'በተሳካ ሁኔታ ተጠናቋል!'
                : 'Completed successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Return to practice style screen to refresh progress
      Navigator.pop(context);
    } catch (e) {
      print('Error saving type mode progress: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.settings.language == 'am'
                ? 'የሚያዝያ ስህተት ተከስቷል'
                : 'An error occurred while saving progress',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.settings.language == 'am'
        ? widget.verse.verseText
        : widget.verse.translation;

    return Scaffold(
      backgroundColor: widget.settings.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: widget.settings.isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.settings.language == 'am' ? 'መጻፍ' : 'Type',
          style: TextStyle(
            color: widget.settings.isDarkMode ? Colors.white : Colors.black,
            fontSize: widget.settings.fontSize,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.settings.language == 'am'
                    ? widget.verse.reference
                    : widget.verse.referenceTranslation,
                style: TextStyle(
                  fontSize: widget.settings.fontSize - 2,
                  color: widget.settings.isDarkMode
                      ? Colors.white70
                      : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                maxLines: 5,
                style: TextStyle(
                  fontSize: widget.settings.fontSize,
                  color: widget.settings.isDarkMode
                      ? Colors.white
                      : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: widget.settings.language == 'am'
                      ? 'ጥቅሱን ይፃፉ...'
                      : 'Type the verse...',
                  hintStyle: TextStyle(
                    fontSize: widget.settings.fontSize,
                    color: widget.settings.isDarkMode
                        ? Colors.white38
                        : Colors.black38,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: widget.settings.isDarkMode
                          ? Colors.white24
                          : Colors.black12,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: widget.settings.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
                onChanged: (value) {
                  // Force accuracy recalculation on text change
                  _calculateAccuracy();
                },
              ),
              if (_suggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _suggestions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return ActionChip(
                        label: Text(
                          _suggestions[index],
                          style: TextStyle(
                            fontSize: widget.settings.fontSize - 2,
                            color: widget.settings.isDarkMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        backgroundColor: widget.settings.isDarkMode
                            ? Colors.grey[800]
                            : Colors.grey[200],
                        onPressed: () => _insertSuggestion(_suggestions[index]),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.settings.language == 'am' ? 'ትክክለኛነት' : 'Accuracy'}: ${_accuracy.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: widget.settings.fontSize,
                      fontWeight: FontWeight.bold,
                      color: widget.settings.isDarkMode
                          ? Colors.white70
                          : Colors.black87,
                    ),
                  ),
                  Text(
                    '${widget.settings.language == 'am' ? 'ሙከራዎች' : 'Attempts'}: $_totalAttempts',
                    style: TextStyle(
                      fontSize: widget.settings.fontSize,
                      fontWeight: FontWeight.bold,
                      color: widget.settings.isDarkMode
                          ? Colors.white70
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
              _buildAccuracyHistory(),
              const SizedBox(height: 24),
              if (_showAnswer)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.settings.isDarkMode
                        ? Colors.grey[900]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.settings.language == 'am'
                            ? 'ትክክለኛ መልስ:'
                            : 'Correct Answer:',
                        style: TextStyle(
                          fontSize: widget.settings.fontSize,
                          fontWeight: FontWeight.bold,
                          color: widget.settings.isDarkMode
                              ? Colors.white70
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: widget.settings.fontSize,
                          color: widget.settings.isDarkMode
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showAnswer = !_showAnswer;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _showAnswer
                        ? (widget.settings.language == 'am'
                            ? 'መልሱን ደብቅ'
                            : 'Hide Answer')
                        : (widget.settings.language == 'am'
                            ? 'መልሱን አሳይ'
                            : 'Show Answer'),
                    style: TextStyle(
                      fontSize: widget.settings.fontSize,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccuracyHistory() {
    if (_accuracyHistory.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          widget.settings.language == 'am' ? 'የእርስዎ ሙከራዎች:' : 'Your Attempts:',
          style: TextStyle(
            fontSize: widget.settings.fontSize - 2,
            fontWeight: FontWeight.w500,
            color: widget.settings.isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _accuracyHistory.length,
            itemBuilder: (context, index) {
              final accuracy = _accuracyHistory[index];
              final isLatest = index == _accuracyHistory.length - 1;

              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isLatest
                      ? (widget.settings.isDarkMode
                          ? Colors.blue[900]
                          : Colors.blue[100])
                      : (widget.settings.isDarkMode
                          ? Colors.grey[800]
                          : Colors.grey[200]),
                  borderRadius: BorderRadius.circular(8),
                  border: isLatest
                      ? Border.all(
                          color: widget.settings.isDarkMode
                              ? Colors.blue
                              : Colors.blue[300]!,
                          width: 2,
                        )
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '#${index + 1}',
                      style: TextStyle(
                        fontSize: widget.settings.fontSize - 4,
                        color: widget.settings.isDarkMode
                            ? Colors.white54
                            : Colors.black54,
                      ),
                    ),
                    Text(
                      '${accuracy.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: widget.settings.fontSize - 2,
                        fontWeight:
                            isLatest ? FontWeight.bold : FontWeight.normal,
                        color: widget.settings.isDarkMode
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
