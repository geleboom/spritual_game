import 'package:flutter/material.dart';
import '../../../verses/models/verse.dart';
import '../../../settings/providers/settings_provider.dart';

abstract class BasePracticeModeScreen extends StatefulWidget {
  final Verse verse;
  final SettingsProvider settings;

  const BasePracticeModeScreen({
    Key? key,
    required this.verse,
    required this.settings,
  }) : super(key: key);
}
