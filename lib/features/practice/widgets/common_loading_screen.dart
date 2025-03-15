import 'package:flutter/material.dart';
import 'package:spiritual_game/features/settings/providers/settings_provider.dart';

class CommonLoadingScreen extends StatelessWidget {
  final SettingsProvider settings;

  const CommonLoadingScreen({
    Key? key,
    required this.settings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: settings.isDarkMode
                ? [Colors.black87, Colors.black]
                : [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                settings.language == 'am' ? 'እባክዎ ይጠብቁ...' : 'Loading...',
                style: TextStyle(
                  fontSize: settings.fontSize,
                  color: settings.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
