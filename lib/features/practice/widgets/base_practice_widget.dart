import 'package:flutter/material.dart';
import '../../../features/verses/models/verse.dart';
import '../../../features/settings/providers/settings_provider.dart';

abstract class BasePracticeScreen extends StatefulWidget {
  final Verse verse;
  final SettingsProvider settings;

  const BasePracticeScreen({
    Key? key,
    required this.verse,
    required this.settings,
  }) : super(key: key);
}