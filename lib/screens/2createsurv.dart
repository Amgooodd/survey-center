import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _allowMultipleSubmissions = false; // NEW

  void _addQuestion(bool isFeedback) {
    setState(() {
      if (isFeedback) {
        _questions.add({
          'title': 'Feedback $_questionCount',
          'type': 'feedback',
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
        'departments': _selectedDepartments,
        'allow_multiple_submissions': _allowMultipleSubmissions, // NEW
      });
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
    });
    Navigator.pop(context);
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
          onPressed: () => Navigator.pop(context),
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
              // NEW SECTION STARTS HERE
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
              // NEW SECTION ENDS HERE
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
                    if (question['type'] == 'feedback')
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
                          hintText: "Edit the feedback question",
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
                    child: Text("Add Feedback Question",
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
      bottomNavigationBar: BottomNavigationBarWidget(),
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

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 28, 51, 95),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BottomNavItem(
            icon: Icons.home,
            label: "Home",
            onTap: () {
              Navigator.pushReplacementNamed(context, '/firsrforadminn');
            },
          ),
          BottomNavItem(
            icon: Icons.edit,
            label: "Create Survey",
            isSelected: true,
            onTap: () {
              Navigator.pushReplacementNamed(context, '/createsurvv');
            },
          ),
          BottomNavItem(
            icon: Icons.group,
            label: "Groups",
            onTap: () {
              Navigator.pushReplacementNamed(context, '/groupp');
            },
          ),
          BottomNavItem(
            icon: Icons.navigate_next,
            label: "Add Student",
            onTap: () {
              Navigator.pushNamed(context, '/admin_dashboard');
            },
          ),
        ],
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  const BottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isSelected ? Colors.white : Colors.blueGrey, size: 24),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? Colors.white : Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }
}
