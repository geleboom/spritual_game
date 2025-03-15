import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/settings/providers/settings_provider.dart';

class PracticeCard extends StatelessWidget {
  final Widget child;

  const PracticeCard({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Card(
          color: settings.isDarkMode ? Colors.grey[900] : Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
