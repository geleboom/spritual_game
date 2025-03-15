import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/settings/providers/settings_provider.dart';
import 'main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider()..navigateToTab(0),
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: settings.theme,
          home: MainPage(),
        ),
      ),
    );
  }
}
