import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final String studentId;

  WelcomeScreen({required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome"),
      ),
      body: Center(
        child: Text(
          "Welcome, Student ID: $studentId",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
