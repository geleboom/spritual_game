import 'package:flutter/material.dart';
import '../models/verse.dart';
import '../../../features/settings/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class VerseCard extends StatelessWidget {
  final Verse verse;
  final VoidCallback onTap;

  const VerseCard({Key? key, required this.verse, required this.onTap})
      : super(key: key);

  String _getProgressText(AppSettings settings, int progress) {
    final remembered =
        AppSettings.translations[settings.language]?['remembered'] ?? 'አስታውሰዋል';
    return '$progress% $remembered';
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    final isEnglish = settings.language == 'en';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.blue.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                settings.getVerseReference(verse.id),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                settings.getVerseText(verse.id),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: verse.progress / 100,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                _getProgressText(settings, verse.progress),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
