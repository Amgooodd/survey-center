import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../widgets/Bottom_bar.dart';

class CreateSurvey extends StatefulWidget {
  const CreateSurvey({super.key});
  @override
  _CreateSurveyState createState() => _CreateSurveyState();
}

class _CreateSurveyState extends State<CreateSurvey> {
  final TextEditingController _surveyNameController = TextEditingController();
  List<Map<String, dynamic>> _questions = [];
  int _questionCount = 1;
  final List<String> _departments = ['All', 'Stat', 'Math', 'CS', 'Chemistry'];
  List<String> _selectedDepartments = [];
  bool _allowMultipleSubmissions = false;
  DateTime? _deadline;
  bool _requireExactGroupCombination = false;
  bool _showOnlySelectedDepartments = false;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().then((_) {}).catchError((error) {
      print("Firebase initialization error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Firebase initialization failed. Please check your configuration.")),
      );
    });
  }

  void _addQuestion(bool istextfield) {
    setState(() {
      if (istextfield) {
        _questions.add({
          'title': 'textfield $_questionCount',
          'type': 'textfield',
        });
      } else {
        _questions.add({
          'title': 'Question $_questionCount',
          'type': 'multiple_choice',
          'options': ['Yes', 'No', 'Maybe'],
        });
      }
      _questionCount++;
    });
  }

  Future<void> _addSurveyToDatabase(
      String surveyName, List<Map<String, dynamic>> questions) async {
    try {
      if (_selectedDepartments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select at least one department.")),
        );
        return;
      }

      // Get the current user ID - you'll need to replace this with your actual user ID
      // This could come from your authentication system or a stored value
      String currentUserId =
          FirebaseAuth.instance.currentUser?.uid ?? "unknown";

      final surveyRef =
          await FirebaseFirestore.instance.collection('surveys').add({
        'name': surveyName,
        'questions': questions
            .map((q) => q['type'] == 'multiple_choice'
                ? {
                    'title': q['title'],
                    'options': q['options'],
                    'type': q['type'],
                  }
                : {
                    'title': q['title'],
                    'type': q['type'],
                  })
            .toList(),
        'timestamp': FieldValue.serverTimestamp(),
        'departments':
            _selectedDepartments.map((d) => d.toUpperCase()).toList(),
        'allow_multiple_submissions': _allowMultipleSubmissions,
        'deadline': _deadline,
        'require_exact_group_combination': _requireExactGroupCombination,
        'show_only_selected_departments': _showOnlySelectedDepartments,
        'madyby': currentUserId, // Add the user ID who created the survey
      });
      await _createNotificationsForSurvey(
          surveyRef.id, surveyName, _selectedDepartments);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Survey added successfully!")),
      );
    } catch (e) {
      print("Error adding survey: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add survey. Please try again.")),
      );
    }
  }

  Future<void> _createNotificationsForSurvey(
      String surveyId, String surveyName, List<String> departments) async {
    try {
      List<String> surveyDeptsUpper = departments
          .map((d) => d.toUpperCase())
          .where((d) => d != 'ALL')
          .toList()
        ..sort();

      final studentsQuery = FirebaseFirestore.instance.collection('students');
      Query studentsQueryFiltered;

      if (departments.contains('All')) {
        studentsQueryFiltered = studentsQuery;
      } else {
        if (_requireExactGroupCombination) {
          final exactGroup = surveyDeptsUpper.join('/');
          studentsQueryFiltered =
              studentsQuery.where('group', isEqualTo: exactGroup);
        } else if (_showOnlySelectedDepartments) {
          studentsQueryFiltered =
              studentsQuery.where('group', whereIn: surveyDeptsUpper);
        } else {
          studentsQueryFiltered = studentsQuery.where('departments',
              arrayContainsAny: surveyDeptsUpper);
        }
      }

      QuerySnapshot studentsSnapshot = await studentsQueryFiltered.get();

      if (studentsSnapshot.docs.isEmpty) return;

      final batch = FirebaseFirestore.instance.batch();
      final now = FieldValue.serverTimestamp();

      for (final studentDoc in studentsSnapshot.docs) {
        final notificationRef =
            FirebaseFirestore.instance.collection('notifications').doc();
        batch.set(notificationRef, {
          'surveyId': surveyId,
          'title': 'New Survey: $surveyName',
          'body': 'A new survey is available for your department',
          'departments': departments,
          'createdAt': now,
          'isRead': false,
          'studentId': studentDoc.id,
          'surveyName': surveyName,
        });
      }
      await batch.commit();
    } catch (e) {
      print("Error creating notifications: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send notifications to students")),
      );
    }
  }

  void _finishSurvey() async {
    final String surveyName = _surveyNameController.text.trim();
    if (_selectedDepartments.isEmpty ||
        surveyName.isEmpty ||
        _questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Please enter a survey name, select at least one department, and add at least one question."),
        ),
      );
      return;
    }
    await _addSurveyToDatabase(surveyName, _questions);
    _surveyNameController.clear();
    setState(() {
      _questions = [];
      _questionCount = 1;
      _selectedDepartments = [];
      _deadline = null;
      _requireExactGroupCombination = false;
    });

    Navigator.popUntil(
      context,
      (route) => route.settings.name == '/firsrforadminn',
    );
  }

  Future<void> _selectDeadline() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _deadline = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Create Survey", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 28, 51, 95),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.popUntil(
              context,
              (route) => route.settings.name == '/firsrforadminn',
            );
          },
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create Survey Name",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _surveyNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter survey name",
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Select Departments",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _departments.map((department) {
                  bool isSelectable = department == 'All' ||
                      !_selectedDepartments.contains('All');
                  return FilterChip(
                    label: Text(department),
                    selected: _selectedDepartments.contains(department),
                    onSelected: (isSelected) {
                      if (!isSelectable) return;
                      setState(() {
                        if (department == 'All') {
                          _selectedDepartments = isSelected ? ['All'] : [];
                        } else {
                          if (isSelected) {
                            _selectedDepartments.add(department);
                          } else {
                            _selectedDepartments.remove(department);
                          }
                        }
                      });
                    },
                    backgroundColor: isSelectable ? null : Colors.grey[300],
                  );
                }).toList(),
              ),
              SizedBox(height: 30),
              Column(
                children: [
                  SwitchListTile(
                    title: Text("Exact Department"),
                    subtitle: Text(
                        "Show only to students in exactly these departments"),
                    value: _requireExactGroupCombination,
                    onChanged: _selectedDepartments.contains('All')
                        ? null
                        : (value) {
                            setState(() {
                              _requireExactGroupCombination = value;
                              if (value) _showOnlySelectedDepartments = false;
                            });
                          },
                  ),
                  SwitchListTile(
                    title: Text("Separate Departments"),
                    subtitle:
                        Text("Show to each selected department individually"),
                    value: _showOnlySelectedDepartments,
                    onChanged: _selectedDepartments.contains('All')
                        ? null
                        : (value) {
                            if (value == true &&
                                _selectedDepartments.length < 2) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "You must select at least 2 departments for this option")),
                              );
                              return;
                            }
                            setState(() {
                              _showOnlySelectedDepartments = value;
                              if (value) _requireExactGroupCombination = false;
                            });
                          },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                "Set Deadline",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 253, 200, 0),
                ),
                onPressed: _selectDeadline,
                child: Text(
                  _deadline != null
                      ? DateFormat('yyyy-MM-dd HH:mm').format(_deadline!)
                      : "Add Deadline",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 30),
              Text(
                "Submission Settings",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_allowMultipleSubmissions
                          ? Color.fromARGB(255, 253, 200, 0)
                          : Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _allowMultipleSubmissions = false),
                    child: Text("Once", style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _allowMultipleSubmissions
                          ? Color.fromARGB(255, 253, 200, 0)
                          : Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _allowMultipleSubmissions = true),
                    child: Text("Multiple Times",
                        style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text(
                "Create Survey Questions",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
              ),
              SizedBox(height: 20),
              ..._questions.asMap().entries.map((entry) {
                final index = entry.key;
                final question = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            question['title'],
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteQuestion(index),
                        ),
                      ],
                    ),
                    if (question['type'] == 'multiple_choice')
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            question['title'] = value;
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[200],
                          hintText: "Edit the question",
                        ),
                      ),
                    if (question['type'] == 'multiple_choice')
                      Column(
                        children: [
                          ...question['options']
                              .asMap()
                              .entries
                              .map((optionEntry) {
                            final optionIndex = optionEntry.key;
                            final option = optionEntry.value;
                            return Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller:
                                        TextEditingController(text: option),
                                    onChanged: (newValue) {
                                      _editOption(
                                          question, optionIndex, newValue);
                                    },
                                    decoration: InputDecoration(
                                      labelText: "Option ${optionIndex + 1}",
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteOption(question, option);
                                  },
                                ),
                              ],
                            );
                          }).toList(),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    question['options'].add('New Option');
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    if (question['type'] == 'textfield')
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            question['title'] = value;
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[200],
                          hintText: "Edit the textfield question",
                        ),
                      ),
                    SizedBox(height: 20),
                  ],
                );
              }),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 253, 200, 0)),
                    onPressed: () => _addQuestion(false),
                    child: Text("Add Multiple Choice Question",
                        style: TextStyle(color: Colors.black)),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 253, 200, 0)),
                    onPressed: () => _addQuestion(true),
                    child: Text("Add Textfield Question",
                        style: TextStyle(color: Colors.black)),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 253, 200, 0)),
                    onPressed: _finishSurvey,
                    child: Text("Finish the survey",
                        style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        survv: true,
      ),
    );
  }

  void _deleteOption(Map<String, dynamic> question, String option) {
    setState(() {
      question['options'].remove(option);
    });
  }

  void _editOption(Map<String, dynamic> question, int index, String newValue) {
    setState(() {
      question['options'][index] = newValue;
    });
  }

  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }
}
