import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
 
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  void _login(BuildContext context) {
    final String nationalId = _nationalIdController.text;
    final String password = _passwordController.text;

    if (nationalId.isNotEmpty && password.isNotEmpty) {
      print(
          "National ID: ${_nationalIdController.text}, Password: ${_passwordController.text}");
    } else {
      String message = "";
      if (nationalId.isEmpty && password.isEmpty) {
        message = "Please enter both National ID and Password";
      } else if (nationalId.isEmpty) {
        message = "Please enter National ID";
      } else if (password.isEmpty) {
        message = "Please enter Password";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Login", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nationalIdController,
                decoration: InputDecoration(
                  labelText: "National ID",
                  hintText: "Enter your National ID",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Enter your password",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _login(context),
                child: Text("Login", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
