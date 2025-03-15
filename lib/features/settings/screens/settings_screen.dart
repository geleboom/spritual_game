import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final translations = SettingsProvider.translations[settings.language] ?? 
        SettingsProvider.translations['am']!;

    return Scaffold(
      appBar: AppBar(
        title: Text(translations['settings']!),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Language Settings
            Card(
              child: ListTile(
                title: Text(translations['language']!),
                subtitle: Text(settings.language == 'am'
                    ? translations['amharic']!
                    : translations['english']!),
                trailing: const Icon(Icons.language),
                onTap: () =>
                    _showLanguageDialog(context, settings, translations),
              ),
            ),
            const SizedBox(height: 16),

            // Font Size Settings
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(translations['fontSize']!),
                  ),
                  Slider(
                    value: settings.fontSize,
                    min: 12.0,
                    max: 24.0,
                    divisions: 12,
                    label: settings.fontSize.round().toString(),
                    onChanged: (value) => settings.setFontSize(value),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      translations['sampleText']!,
                      style: TextStyle(fontSize: settings.fontSize),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Theme Settings
            Card(
              child: SwitchListTile(
                title: Text(translations['darkMode']!),
                value: settings.isDarkMode,
                onChanged: (value) => settings.setDarkMode(value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider settings,
      Map<String, String> translations) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: settings.isDarkMode ? Colors.black87 : Colors.white,
          title: Text(translations['chooseLanguage']!),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('አማርኛ'),
                leading: Radio<String>(
                  value: 'am',
                  groupValue: settings.language,
                  onChanged: (value) {
                    settings.setLanguage(value!);
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('English'),
                leading: Radio<String>(
                  value: 'en',
                  groupValue: settings.language,
                  onChanged: (value) {
                    settings.setLanguage(value!);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
