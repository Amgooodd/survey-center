/*
admin home
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_questionnaire/screens/Auth/login_page.dart';
import '../../widgets/Bottom_bar.dart';
import 'survey_details.dart';

class FirstForAdmin extends StatefulWidget {
  const FirstForAdmin({super.key});

  @override
  _FirstForAdminState createState() => _FirstForAdminState();
}

class _FirstForAdminState extends State<FirstForAdmin> {
  late Stream<List<DocumentSnapshot>> _surveysStream;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _selectedDepartments = {};

  final List<String> _departments = ['CS', 'Stat', 'Math'];

  @override
  void initState() {
    super.initState();
    _surveysStream = FirebaseFirestore.instance
        .collection('surveys')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  void _refreshSurveys() {
    setState(() {
      _surveysStream = FirebaseFirestore.instance
          .collection('surveys')
          .snapshots()
          .map((snapshot) => snapshot.docs);
    });
  }

  void _clearFilter(String department) {
    setState(() {
      _selectedDepartments.remove(department);
    });
  }

  // ignore: unused_element
  void _showFilterOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter by Departments'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _departments.map((department) {
              return CheckboxListTile(
                title: Text(department),
                value: _selectedDepartments.contains(department),
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      _selectedDepartments.add(department);
                    } else {
                      _selectedDepartments.remove(department);
                    }
                  });
                  Navigator.pop(context);
                  _showFilterOptions(context);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home for Admin", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 28, 51, 95),
        leading: IconButton(
          icon: Icon(Icons.logout, color: Colors.red),
          onPressed: () => logout(context),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search surveys...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.filter_list),
                      itemBuilder: (context) => _departments.map((department) {
                        return PopupMenuItem<String>(
                          value: department,
                          child: Row(
                            children: [
                              Checkbox(
                                value:
                                    _selectedDepartments.contains(department),
                                onChanged: (value) {
                                  setState(() {
                                    if (value!) {
                                      _selectedDepartments.add(department);
                                    } else {
                                      _selectedDepartments.remove(department);
                                    }
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              Text(department),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                if (_selectedDepartments.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Wrap(
                      spacing: 8.0,
                      children: _selectedDepartments.map((department) {
                        return Chip(
                          label: Text(department),
                          deleteIcon: Icon(Icons.close, size: 16),
                          onDeleted: () => _clearFilter(department),
                        );
                      }).toList(),
                    ),
                  ),
                SizedBox(height: 20),
                Text(
                  'Create a New Survey',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Text(
                  'Follow the instructions to create your survey.',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 253, 200, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () async {
                        await Navigator.pushNamed(context, '/createsurvv');
                        _refreshSurveys();
                      },
                      child: Row(
                        children: [
                          Icon(Icons.add, color: Colors.black),
                          Text(' Create Survey',
                              style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 253, 200, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/groupp');
                  },
                  child: Row(
                    children: [
                      Icon(Icons.remove_red_eye, color: Colors.black),
                      Text(' View groups',
                          style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Surveys',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(height: 10),
                Container(
                  height: 330,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: StreamBuilder<List<DocumentSnapshot>>(
                      stream: _surveysStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.data == null || snapshot.data!.isEmpty) {
                          return Center(child: Text("No surveys available."));
                        }

                        final filteredSurveys = snapshot.data!.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final name =
                              data['name']?.toString().toLowerCase() ?? '';
                          final departments =
                              (data['departments'] as List<dynamic>?)
                                      ?.map((d) => d.toString().toLowerCase())
                                      .toSet() ??
                                  {};
                          return name.contains(_searchQuery) &&
                              (_selectedDepartments.isEmpty ||
                                  _selectedDepartments.every((dep) =>
                                      departments.contains(dep.toLowerCase())));
                        }).toList();

                        filteredSurveys.sort((a, b) {
                          final aData = a.data() as Map<String, dynamic>;
                          final bData = b.data() as Map<String, dynamic>;
                          final aTimestamp = aData['timestamp'] as Timestamp?;
                          final bTimestamp = bData['timestamp'] as Timestamp?;
                          if (aTimestamp == null || bTimestamp == null) {
                            return 0;
                          }
                          return bTimestamp.compareTo(aTimestamp);
                        });

                        return Column(
                          children: filteredSurveys.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final questions = data['questions'] ?? [];
                            final departments =
                                (data['departments'] as List<dynamic>?)
                                        ?.map((d) => d.toString())
                                        .join(', ') ??
                                    'Unknown Departments';
                            final timestamp = data['timestamp'] as Timestamp?;
                            final formattedTime = timestamp != null
                                ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}'
                                : 'N/A';

                            return SurveyCard(
                              title: data['name'] ?? 'Unnamed Survey',
                              subtitle: '${questions.length} questions',
                              departments: departments,
                              image: "assets/minipic3.jpg",
                              createdAt: formattedTime,
                              survey: doc,
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(homee: true),
    );
  }
}

class SurveyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String departments;
  final String image;
  final String createdAt;
  final DocumentSnapshot survey;

  const SurveyCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.departments,
    required this.image,
    required this.createdAt,
    required this.survey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black, blurRadius: 2)],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    Text(
                      'Departments: $departments',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    Text(
                      'Created: $createdAt',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    SizedBox(height: 10),
                    Flexible(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 253, 200, 0)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SurveyDetailsScreen(survey: survey),
                            ),
                          );
                        },
                        child: Text('View Details',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 100,
              height: 80,
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
/////////////////////////////////////
/* 
create survey

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

    Navigator.pushNamed(context, '/firsrforadminn');
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
            Navigator.pushNamed(context, '/firsrforadminn');
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


*/

/*
++++
survey details
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_questionnaire/Features/download_excel.dart';
import 'surveys_analytics.dart';

class SurveyDetailsScreen extends StatefulWidget {
  final DocumentSnapshot survey;
  const SurveyDetailsScreen({super.key, required this.survey});

  @override
  _SurveyDetailsScreenState createState() => _SurveyDetailsScreenState();
}

class _SurveyDetailsScreenState extends State<SurveyDetailsScreen> {
  Future<void> _deleteSurvey() async {
    await FirebaseFirestore.instance
        .collection('surveys')
        .doc(widget.survey.id)
        .delete();
    Navigator.pop(context);
  }

  Future<void> _endSurvey() async {
    await FirebaseFirestore.instance
        .collection('surveys')
        .doc(widget.survey.id)
        .update({
      'deadline': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Survey has been ended and marked as expired.")),
    );
  }

  Future<void> _resetSurvey() async {
    await FirebaseFirestore.instance
        .collection('surveys')
        .doc(widget.survey.id)
        .update({
      'deadline': null,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Survey has been reset and is now active.")),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this survey?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _deleteSurvey();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditQuestionDialog(Map<String, dynamic> question) async {
    TextEditingController questionController =
        TextEditingController(text: question['title']);
    List<TextEditingController> optionControllers = [];
    if (question['type'] == 'multiple_choice') {
      optionControllers = List.from(question['options'] ?? [])
          .map((option) => TextEditingController(text: option))
          .toList();
    }
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Edit Question'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: questionController,
                    decoration: InputDecoration(labelText: 'Question Text'),
                  ),
                  SizedBox(height: 10),
                  if (question['type'] == 'multiple_choice') ...[
                    ...optionControllers.asMap().entries.map((entry) {
                      int index = entry.key;
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: entry.value,
                              decoration: InputDecoration(
                                  labelText: 'Option ${index + 1}'),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setStateDialog(() {
                                optionControllers.removeAt(index);
                              });
                            },
                          ),
                        ],
                      );
                    }),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setStateDialog(() {
                              optionControllers
                                  .add(TextEditingController(text: ''));
                            });
                          },
                        ),
                        Text('Add Option'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  List<String> updatedOptions = optionControllers
                      .map((controller) => controller.text.trim())
                      .where((text) => text.isNotEmpty)
                      .toList();
                  final updatedQuestion = {
                    'title': questionController.text.trim(),
                    'type': question['type'],
                    'options': updatedOptions,
                  };
                  await FirebaseFirestore.instance
                      .collection('surveys')
                      .doc(widget.survey.id)
                      .update({
                    'questions': FieldValue.arrayRemove([question]),
                  });
                  await FirebaseFirestore.instance
                      .collection('surveys')
                      .doc(widget.survey.id)
                      .update({
                    'questions': FieldValue.arrayUnion([updatedQuestion]),
                  });
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteQuestion(Map<String, dynamic> question) async {
    await FirebaseFirestore.instance
        .collection('surveys')
        .doc(widget.survey.id)
        .update({
      'questions': FieldValue.arrayRemove([question]),
    });
  }

  Future<void> _showAddQuestionDialog(String type) async {
    TextEditingController questionController = TextEditingController();
    List<TextEditingController> optionControllers = [];
    if (type == 'multiple_choice') {
      optionControllers =
          List.generate(3, (index) => TextEditingController(text: ''));
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(
                'Add ${type == 'multiple_choice' ? 'Multiple Choice' : 'Feedback'} Question'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: questionController,
                    decoration: InputDecoration(labelText: 'Question Text'),
                  ),
                  if (type == 'multiple_choice') ...[
                    SizedBox(height: 10),
                    ...optionControllers.asMap().entries.map((entry) {
                      int index = entry.key;
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: entry.value,
                              decoration: InputDecoration(
                                  labelText: 'Option ${index + 1}'),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setStateDialog(() {
                                optionControllers.removeAt(index);
                              });
                            },
                          ),
                        ],
                      );
                    }),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setStateDialog(() {
                              optionControllers
                                  .add(TextEditingController(text: ''));
                            });
                          },
                        ),
                        Text('Add Option'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final questionText = questionController.text.trim();
                  if (questionText.isEmpty) return;
                  List<String> options = [];
                  if (type == 'multiple_choice') {
                    options = optionControllers
                        .map((controller) => controller.text.trim())
                        .where((text) => text.isNotEmpty)
                        .toList();
                    if (options.isEmpty) return;
                  }
                  final newQuestion = {
                    'title': questionText,
                    'type': type,
                    if (type == 'multiple_choice') 'options': options,
                  };
                  await FirebaseFirestore.instance
                      .collection('surveys')
                      .doc(widget.survey.id)
                      .update({
                    'questions': FieldValue.arrayUnion([newQuestion]),
                  });
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddQuestionTypeDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.list),
                title: Text('Multiple Choice'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddQuestionDialog('multiple_choice');
                },
              ),
              ListTile(
                leading: Icon(Icons.feedback),
                title: Text('Feedback'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddQuestionDialog('feedback');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('surveys')
          .doc(widget.survey.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text('Survey Details')),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final questions = data['questions'] ?? [];
        final departments =
            (data['departments'] as List?)?.join(', ') ?? 'Unknown Departments';
        final timestamp = data['timestamp'] as Timestamp?;
        final formattedTime = timestamp != null
            ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}'
            : 'N/A';
        return Scaffold(
          appBar: AppBar(
            title: Text(data['name'] ?? 'Unnamed Survey',
                style: TextStyle(color: Colors.white)),
            backgroundColor: const Color.fromARGB(255, 28, 51, 95),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/firsrforadminn');
              },
            ),
            centerTitle: true,
            actions: [
              PopupMenuButton<String>(
                icon: Icon(Icons.settings, color: Colors.white),
                onSelected: (value) async {
                  switch (value) {
                    case 'download':
                      await SurveyExporter()
                          .exportSurveyResponses(widget.survey.id);
                      break;
                    case 'end':
                      await _endSurvey();
                      break;
                    case 'reset':
                      await _resetSurvey();
                      break;
                    case 'delete':
                      _showDeleteConfirmation();
                      break;
                    case 'analytics':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SurveyAnalysisPage(surveyId: widget.survey.id),
                        ),
                      );
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'download',
                    child: Row(
                      children: [
                        Icon(Icons.download, color: Colors.green),
                        SizedBox(width: 10),
                        Text('Download responses'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'end',
                    child: Row(
                      children: [
                        Icon(Icons.stop_circle, color: Colors.orange),
                        SizedBox(width: 10),
                        Text('End Survey'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'reset',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, color: Colors.blue),
                        SizedBox(width: 10),
                        Text('Reset Survey'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Delete Survey'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Departments: $departments',
                  style: TextStyle(fontSize: 15),
                ),
                Text(
                  'Created At: $formattedTime',
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(height: 20),
                Text('Questions:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      return Card(
                        child: ListTile(
                          title: Text(question['title'] ?? 'No Question Text'),
                          subtitle: question['type'] == 'multiple_choice'
                              ? Text(
                                  'Options: ${question['options'].join(', ')}')
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  _showEditQuestionDialog(question);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteQuestion(question);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SurveyAnalysisPage(surveyId: widget.survey.id),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 253, 200, 0),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.analytics, color: Colors.black),
                          SizedBox(width: 10),
                          Text(
                            'Analytics',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 28, 51, 95),
            onPressed: _showAddQuestionTypeDialog,
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}



*/

/* admin home only his 

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_questionnaire/screens/Auth/login_page.dart';
import '../../widgets/Bottom_bar.dart';
import 'survey_details.dart';

class FirstForAdmin extends StatefulWidget {
  const FirstForAdmin({super.key});

  @override
  _FirstForAdminState createState() => _FirstForAdminState();
}

class _FirstForAdminState extends State<FirstForAdmin> {
  late Stream<List<DocumentSnapshot>> _surveysStream;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _selectedDepartments = {};

  final List<String> _departments = ['CS', 'Stat', 'Math'];

  @override
  void initState() {
    super.initState();
    _surveysStream = FirebaseFirestore.instance
        .collection('surveys')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  void _refreshSurveys() {
    setState(() {
      _surveysStream = FirebaseFirestore.instance
          .collection('surveys')
          .snapshots()
          .map((snapshot) => snapshot.docs);
    });
  }

  void _clearFilter(String department) {
    setState(() {
      _selectedDepartments.remove(department);
    });
  }

  // ignore: unused_element
  void _showFilterOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter by Departments'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _departments.map((department) {
              return CheckboxListTile(
                title: Text(department),
                value: _selectedDepartments.contains(department),
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      _selectedDepartments.add(department);
                    } else {
                      _selectedDepartments.remove(department);
                    }
                  });
                  Navigator.pop(context);
                  _showFilterOptions(context);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home for Admin", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 28, 51, 95),
        leading: IconButton(
          icon: Icon(Icons.logout, color: Colors.red),
          onPressed: () => logout(context),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search surveys...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.filter_list),
                      itemBuilder: (context) => _departments.map((department) {
                        return PopupMenuItem<String>(
                          value: department,
                          child: Row(
                            children: [
                              Checkbox(
                                value:
                                    _selectedDepartments.contains(department),
                                onChanged: (value) {
                                  setState(() {
                                    if (value!) {
                                      _selectedDepartments.add(department);
                                    } else {
                                      _selectedDepartments.remove(department);
                                    }
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              Text(department),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                if (_selectedDepartments.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Wrap(
                      spacing: 8.0,
                      children: _selectedDepartments.map((department) {
                        return Chip(
                          label: Text(department),
                          deleteIcon: Icon(Icons.close, size: 16),
                          onDeleted: () => _clearFilter(department),
                        );
                      }).toList(),
                    ),
                  ),
                SizedBox(height: 20),
                Text(
                  'Create a New Survey',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Text(
                  'Follow the instructions to create your survey.',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 253, 200, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () async {
                        await Navigator.pushNamed(context, '/createsurvv');
                        _refreshSurveys();
                      },
                      child: Row(
                        children: [
                          Icon(Icons.add, color: Colors.black),
                          Text(' Create Survey',
                              style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 253, 200, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/groupp');
                  },
                  child: Row(
                    children: [
                      Icon(Icons.remove_red_eye, color: Colors.black),
                      Text(' View groups',
                          style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Surveys',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(height: 10),
                Container(
                  height: 330,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: StreamBuilder<List<DocumentSnapshot>>(
                      stream: _surveysStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.data == null || snapshot.data!.isEmpty) {
                          return Center(child: Text("No surveys available."));
                        }

                        // Get current user ID - replace this with your actual user ID retrieval
                        String currentUserId =
                            FirebaseAuth.instance.currentUser?.uid ?? "";

                        final filteredSurveys = snapshot.data!.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final name =
                              data['name']?.toString().toLowerCase() ?? '';
                          final departments =
                              (data['departments'] as List<dynamic>?)
                                      ?.map((d) => d.toString().toLowerCase())
                                      .toSet() ??
                                  {};
                          final createdBy = data['madyby']?.toString() ?? '';

                          // Only show surveys created by the current user
                          return createdBy == currentUserId &&
                              name.contains(_searchQuery) &&
                              (_selectedDepartments.isEmpty ||
                                  _selectedDepartments.every((dep) =>
                                      departments.contains(dep.toLowerCase())));
                        }).toList();

                        filteredSurveys.sort((a, b) {
                          final aData = a.data() as Map<String, dynamic>;
                          final bData = b.data() as Map<String, dynamic>;
                          final aTimestamp = aData['timestamp'] as Timestamp?;
                          final bTimestamp = bData['timestamp'] as Timestamp?;
                          if (aTimestamp == null || bTimestamp == null) {
                            return 0;
                          }
                          return bTimestamp.compareTo(aTimestamp);
                        });

                        return Column(
                          children: filteredSurveys.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final questions = data['questions'] ?? [];
                            final departments =
                                (data['departments'] as List<dynamic>?)
                                        ?.map((d) => d.toString())
                                        .join(', ') ??
                                    'Unknown Departments';
                            final timestamp = data['timestamp'] as Timestamp?;
                            final formattedTime = timestamp != null
                                ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}'
                                : 'N/A';

                            return SurveyCard(
                              title: data['name'] ?? 'Unnamed Survey',
                              subtitle: '${questions.length} questions',
                              departments: departments,
                              image: "assets/minipic3.jpg",
                              createdAt: formattedTime,
                              survey: doc,
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(homee: true),
    );
  }
}

class SurveyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String departments;
  final String image;
  final String createdAt;
  final DocumentSnapshot survey;

  const SurveyCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.departments,
    required this.image,
    required this.createdAt,
    required this.survey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black, blurRadius: 2)],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    Text(
                      'Departments: $departments',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    Text(
                      'Created: $createdAt',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    SizedBox(height: 10),
                    Flexible(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 253, 200, 0)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SurveyDetailsScreen(survey: survey),
                            ),
                          );
                        },
                        child: Text('View Details',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 100,
              height: 80,
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


*/

/* 

survey create add his 

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

    Navigator.pushNamed(context, '/firsrforadminn');
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
            Navigator.pushNamed(context, '/firsrforadminn');
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


*/

/*

survey details modified 

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_questionnaire/Features/download_excel.dart';
import 'surveys_analytics.dart';

class SurveyDetailsScreen extends StatefulWidget {
  final DocumentSnapshot survey;
  const SurveyDetailsScreen({super.key, required this.survey});

  @override
  _SurveyDetailsScreenState createState() => _SurveyDetailsScreenState();
}

class _SurveyDetailsScreenState extends State<SurveyDetailsScreen> {
  Future<void> _deleteSurvey() async {
    await FirebaseFirestore.instance
        .collection('surveys')
        .doc(widget.survey.id)
        .delete();
    Navigator.pop(context);
  }

  Future<void> _endSurvey() async {
    await FirebaseFirestore.instance
        .collection('surveys')
        .doc(widget.survey.id)
        .update({
      'deadline': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Survey has been ended and marked as expired.")),
    );
  }

  Future<void> _resetSurvey() async {
    await FirebaseFirestore.instance
        .collection('surveys')
        .doc(widget.survey.id)
        .update({
      'deadline': null,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Survey has been reset and is now active.")),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this survey?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _deleteSurvey();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditQuestionDialog(Map<String, dynamic> question) async {
    TextEditingController questionController =
        TextEditingController(text: question['title']);
    List<TextEditingController> optionControllers = [];
    if (question['type'] == 'multiple_choice') {
      optionControllers = List.from(question['options'] ?? [])
          .map((option) => TextEditingController(text: option))
          .toList();
    }
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Edit Question'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: questionController,
                    decoration: InputDecoration(labelText: 'Question Text'),
                  ),
                  SizedBox(height: 10),
                  if (question['type'] == 'multiple_choice') ...[
                    ...optionControllers.asMap().entries.map((entry) {
                      int index = entry.key;
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: entry.value,
                              decoration: InputDecoration(
                                  labelText: 'Option ${index + 1}'),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setStateDialog(() {
                                optionControllers.removeAt(index);
                              });
                            },
                          ),
                        ],
                      );
                    }),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setStateDialog(() {
                              optionControllers
                                  .add(TextEditingController(text: ''));
                            });
                          },
                        ),
                        Text('Add Option'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  List<String> updatedOptions = optionControllers
                      .map((controller) => controller.text.trim())
                      .where((text) => text.isNotEmpty)
                      .toList();
                  final updatedQuestion = {
                    'title': questionController.text.trim(),
                    'type': question['type'],
                    'options': updatedOptions,
                  };
                  await FirebaseFirestore.instance
                      .collection('surveys')
                      .doc(widget.survey.id)
                      .update({
                    'questions': FieldValue.arrayRemove([question]),
                  });
                  await FirebaseFirestore.instance
                      .collection('surveys')
                      .doc(widget.survey.id)
                      .update({
                    'questions': FieldValue.arrayUnion([updatedQuestion]),
                  });
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteQuestion(Map<String, dynamic> question) async {
    await FirebaseFirestore.instance
        .collection('surveys')
        .doc(widget.survey.id)
        .update({
      'questions': FieldValue.arrayRemove([question]),
    });
  }

  Future<void> _showAddQuestionDialog(String type) async {
    TextEditingController questionController = TextEditingController();
    List<TextEditingController> optionControllers = [];
    if (type == 'multiple_choice') {
      optionControllers =
          List.generate(3, (index) => TextEditingController(text: ''));
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(
                'Add ${type == 'multiple_choice' ? 'Multiple Choice' : 'Feedback'} Question'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: questionController,
                    decoration: InputDecoration(labelText: 'Question Text'),
                  ),
                  if (type == 'multiple_choice') ...[
                    SizedBox(height: 10),
                    ...optionControllers.asMap().entries.map((entry) {
                      int index = entry.key;
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: entry.value,
                              decoration: InputDecoration(
                                  labelText: 'Option ${index + 1}'),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setStateDialog(() {
                                optionControllers.removeAt(index);
                              });
                            },
                          ),
                        ],
                      );
                    }),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setStateDialog(() {
                              optionControllers
                                  .add(TextEditingController(text: ''));
                            });
                          },
                        ),
                        Text('Add Option'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final questionText = questionController.text.trim();
                  if (questionText.isEmpty) return;
                  List<String> options = [];
                  if (type == 'multiple_choice') {
                    options = optionControllers
                        .map((controller) => controller.text.trim())
                        .where((text) => text.isNotEmpty)
                        .toList();
                    if (options.isEmpty) return;
                  }
                  final newQuestion = {
                    'title': questionText,
                    'type': type,
                    if (type == 'multiple_choice') 'options': options,
                  };
                  await FirebaseFirestore.instance
                      .collection('surveys')
                      .doc(widget.survey.id)
                      .update({
                    'questions': FieldValue.arrayUnion([newQuestion]),
                  });
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddQuestionTypeDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.list),
                title: Text('Multiple Choice'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddQuestionDialog('multiple_choice');
                },
              ),
              ListTile(
                leading: Icon(Icons.feedback),
                title: Text('Feedback'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddQuestionDialog('feedback');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('surveys')
          .doc(widget.survey.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text('Survey Details')),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final questions = data['questions'] ?? [];
        final departments =
            (data['departments'] as List?)?.join(', ') ?? 'Unknown Departments';
        final timestamp = data['timestamp'] as Timestamp?;
        final formattedTime = timestamp != null
            ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}'
            : 'N/A';
        return Scaffold(
          appBar: AppBar(
            title: Text(data['name'] ?? 'Unnamed Survey',
                style: TextStyle(color: Colors.white)),
            backgroundColor: const Color.fromARGB(255, 28, 51, 95),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/firsrforadminn');
              },
            ),
            centerTitle: true,
            actions: [
              PopupMenuButton<String>(
                icon: Icon(Icons.settings, color: Colors.white),
                onSelected: (value) async {
                  switch (value) {
                    case 'download':
                      await SurveyExporter()
                          .exportSurveyResponses(widget.survey.id);
                      break;
                    case 'end':
                      await _endSurvey();
                      break;
                    case 'reset':
                      await _resetSurvey();
                      break;
                    case 'delete':
                      _showDeleteConfirmation();
                      break;
                    case 'analytics':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SurveyAnalysisPage(surveyId: widget.survey.id),
                        ),
                      );
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'download',
                    child: Row(
                      children: [
                        Icon(Icons.download, color: Colors.green),
                        SizedBox(width: 10),
                        Text('Download responses'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'end',
                    child: Row(
                      children: [
                        Icon(Icons.stop_circle, color: Colors.orange),
                        SizedBox(width: 10),
                        Text('End Survey'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'reset',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, color: Colors.blue),
                        SizedBox(width: 10),
                        Text('Reset Survey'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Delete Survey'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Departments: $departments',
                  style: TextStyle(fontSize: 15),
                ),
                Text(
                  'Created At: $formattedTime',
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(height: 20),
                Text('Questions:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      return Card(
                        child: ListTile(
                          title: Text(question['title'] ?? 'No Question Text'),
                          subtitle: question['type'] == 'multiple_choice'
                              ? Text(
                                  'Options: ${question['options'].join(', ')}')
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  _showEditQuestionDialog(question);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteQuestion(question);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SurveyAnalysisPage(surveyId: widget.survey.id),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 253, 200, 0),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.analytics, color: Colors.black),
                          SizedBox(width: 10),
                          Text(
                            'Analytics',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 28, 51, 95),
            onPressed: _showAddQuestionTypeDialog,
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}



*/

/*

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget(
      {super.key,
      this.homee = false,
      this.survv = false,
      this.groupp = false,
      this.anall = false,
      this.sup = false});
  final bool homee;
  final bool survv;
  final bool groupp;
  final bool anall;
  final bool sup;
  @override
  Widget build(BuildContext context) {
    // Get isSuperAdmin value from the provider
    final userProvider = Provider.of<UserProvider>(context);
    final bool isSuperAdmin = userProvider.isSuperAdmin;

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
            isSelected: homee,
            onTap: () {
              Navigator.pushReplacementNamed(
                context,
                '/firsrforadminn',
              );
            },
          ),
          BottomNavItem(
            icon: Icons.edit,
            label: "Create Survey",
            isSelected: survv,
            onTap: () {
              Navigator.pushReplacementNamed(context, '/createsurvv');
            },
          ),
          BottomNavItem(
            icon: Icons.group,
            label: "Groups",
            isSelected: groupp,
            onTap: () {
              Navigator.pushReplacementNamed(context, '/groupp');
            },
          ),
          BottomNavItem(
            icon: Icons.chat_rounded,
            label: "Analytics",
            isSelected: anall,
            onTap: () {
              Navigator.pushReplacementNamed(context, '/elanall');
            },
          ),
          if (isSuperAdmin)
            BottomNavItem(
              icon: Icons.person_add,
              label: "Add",
              isSelected: sup,
              onTap: () {
                Navigator.pushReplacementNamed(context, '/admin-management');
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



*/
