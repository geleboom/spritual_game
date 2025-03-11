import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'features/settings/providers/settings_provider.dart';
import 'main_page.dart';
import 'features/welcome/screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasSeenWelcome = prefs.getBool('has_seen_welcome') ?? false;

  runApp(MyApp(hasSeenWelcome: hasSeenWelcome));
}

class MyApp extends StatelessWidget {
  final bool hasSeenWelcome;

  const MyApp({super.key, required this.hasSeenWelcome});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppSettings(),
      child: Consumer<AppSettings>(
        builder: (context, settings, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Bible Verses App',
          theme: settings.theme,
          home: hasSeenWelcome ? const MainPage() : const WelcomeScreen(),
        ),
      ),
    );
  }
}
