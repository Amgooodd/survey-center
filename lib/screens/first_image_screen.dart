import 'package:flutter/material.dart';
import '../widgets/animated_button.dart';

class FirstImageScreen extends StatelessWidget {
  const FirstImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/wllppr.png', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 400),
                Text(
                  'Survey Genie',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 28, 51, 95),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Join us to begin your survey journey today!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: const Color.fromARGB(255, 28, 51, 95),
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
              backgroundColor: const Color.fromARGB(255, 28, 51, 95),
              textColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
