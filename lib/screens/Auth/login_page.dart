import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../StudHome/student_home.dart';

enum OTPPurpose { resetPassword }

class CombinedLogin extends StatefulWidget {
  const CombinedLogin({super.key});

  @override
  _CombinedLoginState createState() => _CombinedLoginState();
}

class _CombinedLoginState extends State<CombinedLogin> {
  final TextEditingController _idController = TextEditingController();

  Future<DocumentSnapshot<Map<String, dynamic>>?> _getAdminDoc(
      String id) async {
    try {
      return await FirebaseFirestore.instance
          .collection('admins')
          .doc(id)
          .get();
    } catch (e) {
      print('Error fetching admin doc: $e');
      return null;
    }
  }

  Future<bool> _checkStudentId(String id) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('students').doc(id).get();
      return snapshot.exists;
    } catch (e) {
      print('Error checking student ID: $e');
      return false;
    }
  }

  void _validateId() async {
    final id = _idController.text.trim();
    if (id.isEmpty) return;

    final adminDoc = await _getAdminDoc(id);
    if (adminDoc != null && adminDoc.exists) {
      final data = adminDoc.data()!;
      final storedPass = data['password'] as String?;
      final isFirstLogin = (storedPass == null || storedPass == 'Abc@123');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminLoginPage(
            adminId: id,
            isFirstLogin: isFirstLogin,
          ),
        ),
      );
      return;
    }

    final isStudent = await _checkStudentId(id);
    if (isStudent) {
      final snapshot =
          await FirebaseFirestore.instance.collection('students').doc(id).get();
      final studentGroup = snapshot.data()?['group'] ?? 'default_group';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StudentForm(
            studentId: id,
            studentGroup: studentGroup,
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid ID. Please try again.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 28, 51, 95),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter Your ID',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 28, 51, 95)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                  labelText: 'ID', border: OutlineInputBorder()),
              onEditingComplete: _validateId,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _validateId,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 253, 200, 0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child:
                  const Text('Submit', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminLoginPage extends StatefulWidget {
  final String adminId;
  final bool isFirstLogin;

  const AdminLoginPage(
      {required this.adminId, required this.isFirstLogin, super.key});

  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() async {
    final input = _passwordController.text.trim();
    if (widget.isFirstLogin) {
      if (input == 'Abc@123') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => PasswordResetPage(adminId: widget.adminId)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wrong default password!')));
      }
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(widget.adminId)
          .get();
      if (doc.exists) {
        final data = doc.data();
        final storedPass = data?['password'] as String?;
        if (storedPass == input) {
          Navigator.pushReplacementNamed(context, '/firsrforadminn',
              arguments: widget.adminId);
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Invalid password.')));
        }
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('An error occurred.')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title:
              const Text('Admin login', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 28, 51, 95),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter Your Password',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 28, 51, 95)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: widget.isFirstLogin
                      ? 'Enter default password'
                      : 'Password',
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _handleLogin(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 253, 200, 0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child:
                    const Text('Login', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      );
}

class PasswordResetPage extends StatefulWidget {
  final String adminId;

  const PasswordResetPage({Key? key, required this.adminId}) : super(key: key);

  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  void _submit() {
    final newPass = _newPassController.text.trim();
    final confirmPass = _confirmPassController.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) return;
    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match!')));
      return;
    }

    FirebaseFirestore.instance
        .collection('admins')
        .doc(widget.adminId)
        .update({'password': newPass});
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Password updated.')));
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Set New Password')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _newPassController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'New Password', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPassController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _submit, child: const Text('Submit')),
            ],
          ),
        ),
      );
}
