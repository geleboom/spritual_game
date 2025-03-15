import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/settings/providers/settings_provider.dart';

class VerseScreensaverScreen extends StatefulWidget {
  const VerseScreensaverScreen({super.key});

  @override
  State<VerseScreensaverScreen> createState() => _VerseScreensaverScreenState();
}

class _VerseScreensaverScreenState extends State<VerseScreensaverScreen> {
  int _currentImageIndex = 0;
  late Timer _timer;
  final List<String> _wallpapers = [
    'assets/images/Dailyinjera.org Verse Wallpaper 187 - PC.jpg',
    'assets/images/Dailyinjera.org Verse Wallpaper 93 - PC.jpg',
    'assets/images/Dailyinjera.org Verse Wallpaper 172 - PC.jpg',
    'assets/images/Dailyinjera.org Verse Wallpaper 297 - PC.jpg',
    'assets/images/Dailyinjera.org Verse Wallpaper 124 - PC.jpg',
    // Add more wallpapers as needed
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _wallpapers.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _nextWallpaper() {
    if (mounted) {
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % _wallpapers.length;
      });
    }
  }

  void _previousWallpaper() {
    if (mounted) {
      setState(() {
        _currentImageIndex =
            (_currentImageIndex - 1 + _wallpapers.length) % _wallpapers.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final translations = SettingsProvider.translations[settings.language] ??
        SettingsProvider.translations['am']!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (details) {
          if (details.globalPosition.dx <
              MediaQuery.of(context).size.width / 2) {
            _previousWallpaper();
          } else {
            _nextWallpaper();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.asset(
              _wallpapers[_currentImageIndex],
              fit: BoxFit.cover,
            ),
            // Gradient overlay for better text visibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            // Navigation hints
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Text(
                translations['tap_to_navigate'] ??
                    'Tap left/right to navigate • Press ESC to exit',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
