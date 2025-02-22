import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLogin extends StatefulWidget {
  @override
  _adminLoginState createState() => _adminLoginState();
}

class _adminLoginState extends State<AdminLogin> {
  final TextEditingController _idController = TextEditingController();

  Future<bool> _checkadminId(String id) async {
    try {
     
      final DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('admins').doc(id).get();

      return snapshot.exists;
    } catch (e) {
      print("Error checking admin ID: $e");
      return false; 
    }
  }

  void _validateadminId() async {
    final String id = _idController.text.trim();

    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter your ID.")),
      );
      return;
    }

    bool isValid = await _checkadminId(id);

    if (isValid) {
      
      Navigator.pushReplacementNamed(context, '/admin_dashboard',
          arguments: id);
    } else {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid admin ID. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("admin Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter Your admin ID",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _idController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "admin ID",
                border: OutlineInputBorder(),
              ),
              onEditingComplete:
                  _validateadminId, 
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _validateadminId,
              child: Text("Submit", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
