import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '6firstforstudent.dart';

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

    // التحقق من الـ Student ID في Firestore
    final DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('students').doc(id).get();

    if (snapshot.exists) {
      // الحصول على الـ studentGroup من الـ Firestore
      String studentGroup = snapshot.get('group');

      // الانتقال إلى صفحة StudentForm مع تمرير الـ studentId و studentGroup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StudentForm(
            studentId: id, // تمرير الـ studentId
            studentGroup: studentGroup, // تمرير الـ studentGroup
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
