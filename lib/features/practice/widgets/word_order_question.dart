import 'package:flutter/material.dart';
import '../../../features/settings/providers/settings_provider.dart';

class WordOrderQuestion extends StatefulWidget {
  final List<String> words;
  final String correctOrder;
  final Function(bool isCorrect, String answer) onSubmit;
  final AppSettings settings;

  const WordOrderQuestion({
    Key? key,
    required this.words,
    required this.correctOrder,
    required this.onSubmit,
    required this.settings,
  }) : super(key: key);

  @override
  State<WordOrderQuestion> createState() => _WordOrderQuestionState();
}

class _WordOrderQuestionState extends State<WordOrderQuestion> {
  final List<String> _selectedWords = [];
  List<String> _availableWords = [];

  @override
  void initState() {
    super.initState();
    _availableWords = List.from(widget.words);
  }

  void _selectWord(String word) {
    setState(() {
      _selectedWords.add(word);
      _availableWords.remove(word);
    });
  }

  void _removeWord(int index) {
    setState(() {
      _availableWords.add(_selectedWords[index]);
      _selectedWords.removeAt(index);
    });
  }

  void _submitAnswer() {
    final answer = _selectedWords.join(' ');
    final isCorrect = answer == widget.correctOrder;
    widget.onSubmit(isCorrect, answer);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Selected words area
        if (_selectedWords.isNotEmpty)
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
                      ? 'የተመረጡ ቃላት:'
                      : 'Selected words:',
                  style: TextStyle(
                    fontSize: widget.settings.fontSize - 2,
                    color: widget.settings.isDarkMode
                        ? Colors.white70
                        : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedWords.asMap().entries.map((entry) {
                    return Chip(
                      label: Text(
                        entry.value,
                        style: TextStyle(fontSize: widget.settings.fontSize),
                      ),
                      onDeleted: () => _removeWord(entry.key),
                      backgroundColor: Colors.blue.withOpacity(0.2),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),

        // Available words area
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
                    ? 'ያልተመረጡ ቃላት:'
                    : 'Available words:',
                style: TextStyle(
                  fontSize: widget.settings.fontSize - 2,
                  color: widget.settings.isDarkMode
                      ? Colors.white70
                      : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableWords.map((word) {
                  return ActionChip(
                    label: Text(
                      word,
                      style: TextStyle(
                        fontSize: widget.settings.fontSize,
                        color: widget.settings.isDarkMode
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    onPressed: () => _selectWord(word),
                    backgroundColor: widget.settings.isDarkMode
                        ? Colors.grey[800]
                        : Colors.white,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Confirm button area
        if (_selectedWords.isNotEmpty) ...[
          Text(
            widget.settings.language == 'am'
                ? 'ሁሉንም ቃላት ይምረጡ እና ያረጋግጡ'
                : 'Select all words and confirm',
            style: TextStyle(
              fontSize: widget.settings.fontSize,
              color:
                  widget.settings.isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedWords.length == widget.words.length
                  ? _submitAnswer
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
              ),
              child: Text(
                AppSettings.translations[widget.settings.language]
                        ?['confirm'] ??
                    'አረጋግጥ',
                style: TextStyle(
                  fontSize: widget.settings.fontSize,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
