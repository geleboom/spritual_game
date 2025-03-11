
import 'package:flutter/material.dart';
// import 'third_welcome_page.dart';
// import 'fifth_welcome_page.dart';
class FourthWelcomePage extends StatelessWidget {
  final PageController controller; // PageController to manage navigation

  const FourthWelcomePage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ይህ መተግበሪያ  ለማስታወስ ይረዳዎታል',
              style: TextStyle(color: Colors.white, fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.flash_on, color: Colors.blue),
                  title: Text('በፍላሽ ካርዶች ልምምድ', style: TextStyle(color: Colors.white)),
                ),
                ListTile(
                  leading: Icon(Icons.folder, color: Colors.blue),
                  title: Text('የቡድን ጥቅሶች በመከፋፍል', style: TextStyle(color: Colors.white)),
                ),
                ListTile(
                  leading: Icon(Icons.trending_up, color: Colors.blue),
                  title: Text('የዕለት ተዕለት እንቅስቃሴህን በመመዝገብ', style: TextStyle(color: Colors.white)),
                ),
                ListTile(
                  leading: Icon(Icons.explore, color: Colors.blue),
                  title: Text('አዳዲስ ጥቅሶችን በጥቅስ መዝገብ ላይ ላይ ያግኙ', style: TextStyle(color: Colors.white)),
                ),
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