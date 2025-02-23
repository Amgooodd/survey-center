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

  // Department-related variables
  List<String> _departments = ['Stat', 'Math', 'CS']; // Updated department list

  String? _selectedDepartment;

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
      if (_selectedDepartment == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select a department.")),
        );
        return;
      }

      // Construct the collection name based on the selected department
      String sanitizedDepartmentName =
          _selectedDepartment!.replaceAll(' ', '-').toLowerCase();
      String collectionName = '$sanitizedDepartmentName-surveys';

      await FirebaseFirestore.instance.collection(collectionName).add({
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
        'timestamp': FieldValue.serverTimestamp(), // Add timestamp
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

    if (_selectedDepartment == null ||
        surveyName.isEmpty ||
        _questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Please enter a survey name, select a department, and add at least one question."),
        ),
      );
      return;
    }

    await _addSurveyToDatabase(surveyName, _questions);
    _surveyNameController.clear();
    setState(() {
      _questions = [];
      _questionCount = 1;
      _selectedDepartment = null;
    });
    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Create Survey",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Survey Name
              Text(
                "Create Survey Name",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _surveyNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter survey name",
                ),
              ),

              // Department Dropdown
              SizedBox(height: 20),
              Text(
                "Select Department",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 10),
              InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDepartment,
                    hint: Text('Select a department'),
                    isExpanded: true,
                    items: _departments.map((String department) {
                      return DropdownMenuItem<String>(
                        value: department,
                        child: Text(department),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDepartment = newValue;
                      });
                    },
                  ),
                ),
              ),

              // Questions Section
              SizedBox(height: 30),
              Text(
                "Create Survey Questions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
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
                                fontSize: 18, fontWeight: FontWeight.bold),
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
              }).toList(),

              // Buttons to Add Questions and Finish Survey
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () => _addQuestion(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text("Add Multiple Choice Question",
                        style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _addQuestion(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text("Add Feedback Question",
                        style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _finishSurvey,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text("Finish the survey",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
