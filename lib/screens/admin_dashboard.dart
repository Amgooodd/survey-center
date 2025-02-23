import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  String? _selectedDepartment;
  List<String> departments = [
    'Computer Science',
    'Statistic',
    'Chemistry',
    'Biology',
    'Physics'
  ];

  Future<void> _addStudentToDatabase() async {
    final String studentId = _studentIdController.text.trim();
    final String studentName = _studentNameController.text.trim();
    final String? department = _selectedDepartment;

    if (studentId.isNotEmpty && studentName.isNotEmpty && department != null) {
      try {
        await FirebaseFirestore.instance
            .collection('students')
            .doc(studentId)
            .set({
          'id': studentId,
          'name': studentName,
          'department': department,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Student added successfully!")),
        );
        _studentIdController.clear();
        _studentNameController.clear();
        setState(() {
          _selectedDepartment = null;
        });
      } catch (e) {
        print("Error adding student: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add student. Please try again.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Please enter both Student ID, Name, and select a Department.")),
      );
    }
  }

  void _viewStudents() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewStudentsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _studentIdController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(14),
                FilteringTextInputFormatter.digitsOnly, // Allow only digits
              ],
              decoration: InputDecoration(
                labelText: "Student ID",
                border: OutlineInputBorder(),
                errorText: _studentIdController.text.length != 14 &&
                        _studentIdController.text.isNotEmpty
                    ? "Student ID must be exactly 14 numbers."
                    : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _studentNameController,
              decoration: InputDecoration(
                labelText: "Student Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedDepartment,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDepartment = newValue;
                });
              },
              items: departments.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: "Department",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a department.';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_studentIdController.text.length == 14) {
                  _addStudentToDatabase();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text("Student ID must be exactly 14 numbers.")),
                  );
                }
              },
              child: Text("Add Student", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _viewStudents,
              child:
                  Text("View Students", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
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

class ViewStudentsScreen extends StatefulWidget {
  @override
  _ViewStudentsScreenState createState() => _ViewStudentsScreenState();
}

class _ViewStudentsScreenState extends State<ViewStudentsScreen> {
  Future<void> _editStudent(String studentId, BuildContext context) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentSnapshot snapshot =
        await firestore.collection('students').doc(studentId).get();

    if (snapshot.exists) {
      final Map<String, dynamic>? data =
          snapshot.data() as Map<String, dynamic>?;
      final String? currentName = data?['name'];
      final String? currentDepartment = data?['department'];
      final String? currentId = data?['id'];

      final nameController = TextEditingController(text: currentName);
      final idController = TextEditingController(text: currentId);
      String? selectedDepartment = currentDepartment;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Edit Student"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: "Student ID"),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              DropdownButtonFormField<String>(
                value: selectedDepartment,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDepartment = newValue;
                  });
                },
                items: [
                  'Computer Science',
                  'Statistic',
                  'Chemistry',
                  'Biology',
                  'Physics'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: "Department"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (idController.text.isNotEmpty &&
                    nameController.text.isNotEmpty &&
                    selectedDepartment != null) {
                  await firestore.collection('students').doc(currentId).update({
                    'id': idController.text.trim(),
                    'name': nameController.text.trim(),
                    'department': selectedDepartment!,
                  });

                  if (idController.text.trim() != currentId) {
                    await firestore
                        .collection('students')
                        .doc(idController.text.trim())
                        .set({
                      'id': idController.text.trim(),
                      'name': nameController.text.trim(),
                      'department': selectedDepartment!,
                    });
                    await firestore
                        .collection('students')
                        .doc(currentId)
                        .delete();
                  }

                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please fill all fields.")),
                  );
                }
              },
              child: Text("Save"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _deleteStudent(String studentId) async {
    await FirebaseFirestore.instance
        .collection('students')
        .doc(studentId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Students"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data?.docs ?? [];
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index].data() as Map<String, dynamic>;
              final studentId = students[index].id;
              final name = student['name'] ?? '';
              final department = student['department'] ?? '';

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(name),
                  subtitle: Text(department),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editStudent(studentId, context),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteStudent(studentId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
