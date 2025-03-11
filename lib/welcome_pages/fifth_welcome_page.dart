import 'package:flutter/material.dart';
import '../main_page.dart'; 
class FifthWelcomePage extends StatelessWidget {
  const FifthWelcomePage({super.key}); // Constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ይህ ነው! ዳይ ወደ ማንበብ!',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 40),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green,
              child: Text(
                '100',
                style: TextStyle(color: Colors.white, fontSize: 36),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the main application or another page
                Navigator.pushReplacement(
                  context, 
                   MaterialPageRoute(builder: (context) => const MainPage()),
                );
              },
              child: const Text('እንጀምር'),
            ),
            const SizedBox(height: 20),
            const Text(
              'እኛን በመምረጣችሁ እናመሰግናለን መንፈሳዊ እድገት :)',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}