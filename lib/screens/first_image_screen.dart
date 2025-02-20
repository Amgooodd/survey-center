import 'package:flutter/material.dart';
import '../widgets/animated_button.dart';

class FirstImageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/first_image.png',
                  width: 300, // Keep original size
                  height: 300, // Keep original size
                ),
                SizedBox(height: 20),
                Text(
                  'Survey Center',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Create a survey with multiple questions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: AnimatedButton(
              text: 'Start',
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              backgroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
