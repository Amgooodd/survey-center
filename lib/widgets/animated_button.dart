import 'package:flutter/material.dart';

class AnimatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor; // Added parameter for button background color
  final Color textColor; // Added parameter for text color

  const AnimatedButton({
    required this.text,
    required this.onPressed,
    this.backgroundColor =
        Colors.black, // Default background color set to black
    this.textColor = Colors.white, // Default text color set to white
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor, // Apply custom background color
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        textStyle: TextStyle(fontSize: 18),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(color: textColor), // Use the custom text color
      ),
    );
  }
}
