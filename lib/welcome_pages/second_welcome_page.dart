
import 'package:flutter/material.dart';
// import 'third_welcome_page.dart';
// import 'fifth_welcome_page.dart';
class SecondWelcomePage extends StatelessWidget {
  
final PageController controller; // PageController to manage navigation

  const SecondWelcomePage({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('ጥቅሶችን መምረጥ እና የእርስዎን የማስታወሻ እድገት መከታተል', style: TextStyle(color: Colors.white, fontSize: 24)),
            const SizedBox(height: 40),
            const Column(
              children: [
                ProgressTile(verse: 'ምሳሌ 3:1-2', version: '1954', progress: 75),
                ProgressTile(verse: 'ሮሜ 8:28', version: '1954', progress: 30),
                ProgressTile(verse: 'ዩንሐንስ 3:16', version: '1954', progress: 100),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    // Instead of navigating, you might want to skip directly to the last page
                    controller.jumpToPage(4);
                  },
                  child: const Text('ወደ ዋና ይዘዋውሩ', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {
                    controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                  },
                  child: const Text('ቀጣይ'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressTile extends StatelessWidget {
  final String verse;
  final String version;
  final int progress;

  const ProgressTile({super.key, required this.verse, required this.version, required this.progress});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(verse, style: const TextStyle(color: Colors.white)),
      subtitle: Text(version, style: const TextStyle(color: Colors.white54)),
      trailing: Text('$progress%', style: const TextStyle(color: Colors.white)),
    );
  }
}
