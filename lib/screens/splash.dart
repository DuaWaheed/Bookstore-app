import 'package:flutter/material.dart';
import '../screens/book_loader.dart'; // import the loader

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF3E5F5), // lighter purple
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BookLoader(),
            SizedBox(height: 20),
            Text(
              "Book Hive",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8E24AA),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Loading your next great read...",
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
