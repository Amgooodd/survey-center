import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/StudHome/student_home.dart';

class StudentLogin extends StatefulWidget {
  const StudentLogin({super.key});

  @override
  _StudentLoginState createState() => _StudentLoginState();
}

class _StudentLoginState extends State<StudentLogin> {
  final TextEditingController _idController = TextEditingController();

  Future<void> _validateStudentId() async {
    String id = _idController.text.trim();
    if (id.isEmpty) return;

    final DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('students').doc(id).get();

    if (snapshot.exists) {
      String studentGroup = snapshot.get('group');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StudentForm(
            studentId: id,
            studentGroup: studentGroup,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid student ID. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Login", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 28, 51, 95),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter Your Student ID",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 28, 51, 95)),
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
                backgroundColor: Color.fromARGB(255, 253, 200, 0),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text("Submit", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
