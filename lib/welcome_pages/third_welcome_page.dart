import 'package:flutter/material.dart';

class ThirdWelcomePage extends StatelessWidget {
  final PageController controller; // PageController to manage navigation

  const ThirdWelcomePage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ጥቅሶችን ለመሸምደድ እና የእርስዎን ውጤት ለመጨመር ጨዋታዎች ይጫወቱ',
              style: TextStyle(color: Colors.white, fontSize: 24),
              textAlign: TextAlign.center, // Center the text
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: _buildIconColumn(Icons.book, 'ማንበብ')),
                Expanded(child: _buildIconColumn(Icons.text_fields, 'ባዶ ቦታ መሙላት')),
                Expanded(child: _buildIconColumn(Icons.keyboard, 'መፀሃፈ')),
                Expanded(child: _buildIconColumn(Icons.check_circle, 'ፈተና')),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    controller.jumpToPage(4); // Navigate to the last page
                  },
                  child: const Text(
                    'ወደ ዋና ይዘዋውሩ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
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

  Column _buildIconColumn(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Size to fit content
      children: [
        Icon(icon, color: Colors.blue, size: 40), // Adjust icon size
        const SizedBox(height: 8), // Space between icon and text
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}