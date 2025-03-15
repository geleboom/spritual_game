import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiritual_game/features/verses/models/verse.dart';
import 'package:spiritual_game/features/settings/providers/settings_provider.dart';
import 'package:spiritual_game/features/progress/services/progress_service.dart';
import 'package:spiritual_game/features/profile/models/user_profile.dart';
import 'dart:convert';

class ReadModeScreen extends StatefulWidget {
  final Verse verse;
  final SettingsProvider settings;

  const ReadModeScreen({
    Key? key,
    required this.verse,
    required this.settings,
  }) : super(key: key);

  @override
  State<ReadModeScreen> createState() => _ReadModeScreenState();
}

class _ReadModeScreenState extends State<ReadModeScreen> {
  List<String> _allWords = [];
  List<String> _visibleWords = [];
  int _currentWordIndex = 0;
  static const int _wordsPerTap = 2; // Number of words to reveal per tap

  @override
  void initState() {
    super.initState();
    _initializeWords();
  }

  void _initializeWords() {
    final text = widget.settings.language == 'am'
        ? widget.verse.verseText
        : widget.verse.translation;
    _allWords = text.split(' ');
    _visibleWords = [];
  }

  void _revealNextWords() {
    setState(() {
      for (int i = 0;
          i < _wordsPerTap && _currentWordIndex < _allWords.length;
          i++) {
        _visibleWords.add(_allWords[_currentWordIndex]);
        _currentWordIndex++;
      }
    });

    // Calculate current progress percentage
    final progressPercentage = (_currentWordIndex / _allWords.length) * 100;
    widget.verse.progress = progressPercentage.round();

    // Check if reading is complete
    if (_currentWordIndex >= _allWords.length) {
      _saveProgress();
    }
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressService = ProgressService(prefs);

      print('Saving read mode progress for verse ${widget.verse.id}');

      // Only save progress and update completed verses if the verse is fully read
      if (_currentWordIndex >= _allWords.length) {
        // Save 100% progress when reading is complete
        await progressService.updateProgress(
            widget.verse.id, [true], // Complete
            mode: 'read');

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

        // Verify the saved progress
        final savedProgress = await progressService
            .getVerseProgress(widget.verse.id, mode: 'read');
        print('Verified read mode progress: $savedProgress');

        // Show success message
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
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error saving read mode progress: $e');
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

  void _resetReading() {
    setState(() {
      _visibleWords.clear();
      _currentWordIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.settings.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(widget.settings.language == 'am' ? 'ንባብ' : 'Read'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetReading,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.settings.language == 'am'
                    ? widget.verse.reference
                    : widget.verse.referenceTranslation,
                style: TextStyle(
                  fontSize: widget.settings.fontSize + 4,
                  fontWeight: FontWeight.bold,
                  color: widget.settings.isDarkMode
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GestureDetector(
                  onTap: _revealNextWords,
                  child: Container(
                    width: double.infinity,
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
                          _visibleWords.join(' '),
                          style: TextStyle(
                            fontSize: widget.settings.fontSize + 2,
                            height: 1.5,
                            color: widget.settings.isDarkMode
                                ? Colors.white70
                                : Colors.black87,
                          ),
                        ),
                        if (_currentWordIndex < _allWords.length)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              widget.settings.language == 'am'
                                  ? 'መቀጠል ለማንበብ ይንኩ'
                                  : 'Tap to continue reading',
                              style: TextStyle(
                                fontSize: widget.settings.fontSize - 2,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_currentWordIndex >= _allWords.length)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _resetReading,
                        icon: const Icon(Icons.refresh),
                        label: Text(widget.settings.language == 'am'
                            ? 'እንደገና ያንብቡ'
                            : 'Read Again'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
