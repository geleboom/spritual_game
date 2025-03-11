import 'package:flutter/material.dart';


class FirstWelcomePage extends StatelessWidget {
  final PageController controller;

  const FirstWelcomePage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'እንኳን ደህና መጡ',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 10),
            const Text(
              'መንፈሳዊ እድገት',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '“ነገር ግን በጌታችንና በመድኃኒታችን በኢየሱስ ክርስቶስ ጸጋና እውቀት እደጉ።'
                ' ለእርሱ አሁንም እስከ ዘላለምም ቀን ድረስ ክብር ይሁን፤ አሜን።”',
                style: TextStyle(color: Colors.white54, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '2ኛ ጴጥሮስ 3፥18',
              style: TextStyle(color: Colors.white, fontSize: 14),
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