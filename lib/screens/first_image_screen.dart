import 'package:flutter/material.dart';
import '../widgets/animated_button.dart';

class FirstImageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/first_image.png', // Ensure this is the correct path to your logo image
                  width: 100, // Adjust size as needed
                  height: 100, // Adjust size as needed
                ),
                SizedBox(height: 20),
                Text(
                  'Survey Center',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Join us to begin your survey journey today!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: AnimatedButton(
              text: 'Start Survey',
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              backgroundColor: Colors.white,
              textColor: Colors
                  .black, // Assuming AnimatedButton has a textColor property
            ),
          ),
        ],
      ),
    );
  }
}
