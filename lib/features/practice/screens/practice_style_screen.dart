import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiritual_game/features/verses/models/verse.dart';
import 'package:spiritual_game/features/settings/providers/settings_provider.dart';
import 'package:spiritual_game/features/practice/screens/practice_modes/read_mode_screen.dart';
import 'package:spiritual_game/features/practice/screens/practice_modes/blank_mode_screen.dart';
import 'package:spiritual_game/features/practice/screens/practice_modes/type_mode_screen.dart';
import 'package:spiritual_game/features/practice/screens/practice_screen.dart';
import 'package:spiritual_game/features/practice/screens/practice_modes/test_mode_screen.dart';
import 'package:spiritual_game/features/progress/services/progress_service.dart';

class PracticeStyleScreen extends StatefulWidget {
  final Verse verse;

  const PracticeStyleScreen({
    Key? key,
    required this.verse,
  }) : super(key: key);

  @override
  State<PracticeStyleScreen> createState() => _PracticeStyleScreenState();
}

class _PracticeStyleScreenState extends State<PracticeStyleScreen> {
  bool _isTestModeLocked = true;
  bool _isLoading = true;
  int _overallProgress = 0;

  @override
  void initState() {
    super.initState();
    _checkTestModeLock();
  }

  Future<void> _checkTestModeLock() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressService = ProgressService(prefs);

      // Get progress for each mode
      final readProgress =
          await progressService.getVerseProgress(widget.verse.id, mode: 'read');
      final blankProgress = await progressService
          .getVerseProgress(widget.verse.id, mode: 'blank');
      final typeProgress =
          await progressService.getVerseProgress(widget.verse.id, mode: 'type');

      print('Checking test mode lock for verse ${widget.verse.id}:');
      print('Read mode progress: $readProgress');
      print('Blank mode progress: $blankProgress');
      print('Type mode progress: $typeProgress');

      // Calculate overall progress (average of all modes)
      final totalProgress = readProgress + blankProgress + typeProgress;
      final overallProgress = (totalProgress / 3).round();
      print('Overall progress: $overallProgress%');

      // Test mode is unlocked if all other modes have progress > 0
      final isLocked =
          readProgress <= 0 || blankProgress <= 0 || typeProgress <= 0;
      print('Test mode locked: $isLocked');
      print('Lock reason:');
      if (readProgress <= 0) print('- Read mode not completed');
      if (blankProgress <= 0) print('- Blank mode not completed');
      if (typeProgress <= 0) print('- Type mode not completed');

      setState(() {
        _isTestModeLocked = isLocked;
        _overallProgress = overallProgress;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking test mode lock: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final translations = SettingsProvider.translations[settings.language] ??
            SettingsProvider.translations['am']!;

        return Scaffold(
          backgroundColor: settings.isDarkMode ? Colors.black : Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: settings.isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Progress Indicator
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: CircularProgressIndicator(
                                  value: _overallProgress / 100,
                                  strokeWidth: 8,
                                  backgroundColor: settings.isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF64D2FF),
                                  ),
                                ),
                              ),
                              Text(
                                '$_overallProgress',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: settings.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          translations['choose_practice_style'] ??
                              (settings.language == 'am'
                                  ? 'የልምምድ ዘዴን ይምረጡ'
                                  : 'Choose practice style'),
                          style: TextStyle(
                            fontSize: settings.fontSize + 4,
                            color: settings.isDarkMode
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 1.1,
                          children: [
                            _buildPracticeOption(
                              context: context,
                              icon: Icons.book,
                              label: translations['read'] ??
                                  (settings.language == 'am' ? 'ንባብ' : 'Read'),
                              color: const Color(0xFF64D2FF),
                              onTap: () => _navigateToPractice(context, 'read'),
                              settings: settings,
                            ),
                            _buildPracticeOption(
                              context: context,
                              icon: Icons.space_bar,
                              label: translations['blank'] ??
                                  (settings.language == 'am'
                                      ? 'ባዶ ቦታ'
                                      : 'Blank'),
                              color: const Color(0xFFFF6464),
                              onTap: () =>
                                  _navigateToPractice(context, 'blank'),
                              settings: settings,
                            ),
                            _buildPracticeOption(
                              context: context,
                              icon: Icons.keyboard,
                              label: translations['type'] ??
                                  (settings.language == 'am' ? 'መጻፍ' : 'Type'),
                              color: const Color(0xFF64FF98),
                              onTap: () => _navigateToPractice(context, 'type'),
                              settings: settings,
                            ),
                            _buildPracticeOption(
                              context: context,
                              icon: Icons.quiz,
                              label: translations['test'] ??
                                  (settings.language == 'am' ? 'ፈተና' : 'Test'),
                              color: const Color(0xFFFFB164),
                              onTap: _isTestModeLocked
                                  ? () => _showLockedMessage(context, settings)
                                  : () => _navigateToPractice(context, 'test'),
                              settings: settings,
                              isLocked: _isTestModeLocked,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  void _showLockedMessage(BuildContext context, SettingsProvider settings) {
    final translations = SettingsProvider.translations[settings.language] ??
        SettingsProvider.translations['am']!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          settings.language == 'am'
              ? 'እባክዎ በመጀመሪያ ሌሎች የልምምድ ዘዴዎችን ይጨርሱ'
              : 'Please complete other practice modes first',
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildPracticeOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required SettingsProvider settings,
    bool isLocked = false,
  }) {
    return Card(
      color: settings.isDarkMode ? Colors.grey[900] : Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: isLocked ? Colors.grey : color,
                ),
                if (isLocked)
                  const Icon(
                    Icons.lock,
                    size: 20,
                    color: Colors.grey,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: isLocked
                    ? Colors.grey
                    : (settings.isDarkMode ? Colors.white : Colors.black87),
                fontSize: settings.fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPractice(BuildContext context, String mode) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    Widget screen;
    switch (mode) {
      case 'test':
        screen = TestModeScreen(verse: widget.verse, settings: settings);
        break;
      case 'read':
        screen = ReadModeScreen(verse: widget.verse, settings: settings);
        break;
      case 'blank':
        screen = BlankModeScreen(verse: widget.verse, settings: settings);
        break;
      case 'type':
        screen = TypeModeScreen(verse: widget.verse, settings: settings);
        break;
      default:
        screen = PracticeScreen(verse: widget.verse, practiceMode: mode);
    }

    // Navigate and refresh progress when returning
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => screen))
        .then((_) {
      // Refresh progress when returning from any mode
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
        _checkTestModeLock();
      }
    });
  }
}
