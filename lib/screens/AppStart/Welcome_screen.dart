import 'package:flutter/material.dart';

class FirstImageScreen extends StatelessWidget {
  const FirstImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(6),
                image: const DecorationImage(
                  image: AssetImage("assets/mainpic2.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 450),
                Text(
                  'Survey center',
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
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/complog');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 28, 51, 95),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Start Survey',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
