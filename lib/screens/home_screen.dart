import 'package:flutter/material.dart';
import '../widgets/animated_button.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Choose who are you",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Help us determine which interface is right for you",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Admin screen
                    Navigator.pushNamed(context, '/admin');
                  },
                  child: Column(
                    children: [
                      Image.asset('assets/images/admin.png', height: 100),
                      SizedBox(height: 8),
                      Text("Admin", style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Student screen
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Column(
                    children: [
                      Image.asset('assets/images/student_icon.png',
                          height: 100),
                      SizedBox(height: 8),
                      Text("Student", style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // Handle Continue button press
                // You can add the logic here to navigate to the next screen
              },
              child: Text("Continue", style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
