import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WelcomeScreen extends StatelessWidget {
  final String studentId;

  WelcomeScreen({required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('students')
            .doc(studentId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
           
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
           
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            
            return Center(child: Text("Student not found!"));
          }

          final studentName = snapshot.data!['name'] as String?;

         
          return Center(
            child: Text(
              "Welcome, $studentName!",
              style: TextStyle(fontSize: 20),
            ),
          );
        },
      ),
    );
  }
}
