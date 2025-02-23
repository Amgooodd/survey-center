import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentLogin extends StatefulWidget {
  const StudentLogin({super.key});

  @override
  _StudentLoginState createState() => _StudentLoginState();
}

class _StudentLoginState extends State<StudentLogin> {
  final TextEditingController _idController = TextEditingController();

  Future<void> _validateStudentId() async {
    final String id = _idController.text.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter your ID.")),
      );
      return;
    }

    // Check if the student ID exists in Firestore
    final DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('students').doc(id).get();
    if (snapshot.exists) {
      // Redirect to the welcome screen if the ID is valid
      Navigator.pushReplacementNamed(context, '/studentformm', arguments: id);
    } else {
      // Show an error message if the ID is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid student ID. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter Your Student ID",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _idController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Student ID",
                border: OutlineInputBorder(),
              ),
              onEditingComplete: _validateStudentId,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _validateStudentId,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text("Submit", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
