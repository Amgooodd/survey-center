import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentForm extends StatefulWidget {
  final String studentId;
  final String studentGroup;

  const StudentForm({
    super.key,
    required this.studentId,
    required this.studentGroup,
  });

  @override
  _StudentFormState createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedDepartments = {};

  final List<String> _departments = ['CS', 'Stat', 'Math'];

  Future<List<Map<String, dynamic>>> getSurveys() async {
    List<String> groupComponents = widget.studentGroup
        .split('/')
        .map((e) => e.trim().toUpperCase())
        .toList();

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('surveys').get();

    return snapshot.docs.where((doc) {
      List<dynamic> departments = (doc.data() as Map)['departments'] ?? [];
      return departments
              .any((dept) => dept.toString().trim().toUpperCase() == "ALL") ||
          departments.every(
            (dept) =>
                groupComponents.contains(dept.toString().trim().toUpperCase()),
          );
    }).map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
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
        title: Text("Home for Student", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 28, 51, 95),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          SizedBox(height: 20),
          Positioned(
            top: 158,
            left: 50,
            child: Container(
              width: 390,
              height: 257,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0), // Add horizontal padding
                    child: Row(
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
                              setState(() {});
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.filter_list),
                          itemBuilder: (context) =>
                              _departments.map((department) {
                            return PopupMenuItem<String>(
                              value: department,
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _selectedDepartments
                                        .contains(department),
                                    onChanged: (value) {
                                      setState(() {
                                        if (value!) {
                                          _selectedDepartments.add(department);
                                        } else {
                                          _selectedDepartments
                                              .remove(department);
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
                  ),
                  SizedBox(height: 30),
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
                  Container(
                    width: 350,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                      image: DecorationImage(
                        image: AssetImage("assets/stat_cs.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                SizedBox(height: 30),
                Text(
                  'Your available surveys',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(height: 20),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: getSurveys(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                            child:
                                Text("No surveys available for your group."));
                      }

                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var survey = snapshot.data![index];
                          return Card(
                            margin: EdgeInsets.all(10),
                            child: ListTile(
                              title: Text(survey['name'] ?? 'Untitled Survey'),
                              subtitle: Text(
                                  survey['description'] ?? 'No description'),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(255, 253, 200,
                                      0), // Change background color
                                  foregroundColor:
                                      Colors.black, // Change text color
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SurveyQuestionsPage(
                                        studentId: widget.studentId,
                                        surveyId: survey['id'],
                                        studentGroup: widget
                                            .studentGroup, // ✅ تمرير studentGroup هنا
                                      ),
                                    ),
                                  );
                                },
                                child: Text("Start Survey"),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        studentId: widget.studentId,
        studentGroup: widget.studentGroup,
      ),
    );
  }
}

class SurveyQuestionsPage extends StatefulWidget {
  final String studentId;
  final String surveyId;
  final String studentGroup; // ✅ أضف studentGroup هنا

  const SurveyQuestionsPage({
    super.key,
    required this.studentId,
    required this.surveyId,
    required this.studentGroup, // ✅ استقباله هنا
  });

  @override
  _SurveyQuestionsPageState createState() => _SurveyQuestionsPageState();
}

class _SurveyQuestionsPageState extends State<SurveyQuestionsPage> {
  bool hasSubmitted = false;
  List<Map<String, dynamic>> _questions = [];
  final Map<String, dynamic> _answers = {};
  bool _allowMultipleSubmissions = false; // NEW

  @override
  void initState() {
    super.initState();
    _checkIfSubmitted();
  }

  Future<void> _submitAnswers() async {
    if (_answers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Please answer all questions before submitting.")),
      );
      return;
    }

    // Create new response document instead of overwriting
    await FirebaseFirestore.instance.collection('students_responses').add({
      'studentId': widget.studentId,
      'surveyId': widget.surveyId,
      'answers': _answers,
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (!_allowMultipleSubmissions) {
      setState(() => hasSubmitted = true);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ThankYouPage(
          studentId: widget.studentId,
          studentGroup: widget.studentGroup,
        ),
      ),
    );
  }

  Future<void> _checkIfSubmitted() async {
    // Check survey settings first
    DocumentSnapshot surveySnapshot = await FirebaseFirestore.instance
        .collection('surveys')
        .doc(widget.surveyId)
        .get();

    if (!surveySnapshot.exists) return;

    setState(() {
      _allowMultipleSubmissions =
          surveySnapshot['allow_multiple_submissions'] ?? false;
    });

    if (!_allowMultipleSubmissions) {
      // Check if ANY response exists for this student+survey combination
      QuerySnapshot response = await FirebaseFirestore.instance
          .collection('students_responses')
          .where('studentId', isEqualTo: widget.studentId)
          .where('surveyId', isEqualTo: widget.surveyId)
          .limit(1)
          .get();

      if (response.docs.isNotEmpty) {
        setState(() => hasSubmitted = true);
      } else {
        _loadQuestions();
      }
    } else {
      _loadQuestions();
    }
  }

  Future<void> _loadQuestions() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('surveys')
        .doc(widget.surveyId)
        .get();

    if (snapshot.exists) {
      setState(() {
        _questions = List<Map<String, dynamic>>.from(
            (snapshot.data() as Map)['questions'] ?? []);
      });
    }
  }

  // ✅ دالة لمنع الخروج بدون إرسال الإجابات
  Future<bool> _onWillPop() async {
    if (hasSubmitted || _answers.isEmpty) {
      return true; // خروج عادي إذا تم الإرسال
    }

    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Exit Survey?"),
            content: Text("Your answers will not be saved. Are you sure?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // إلغاء
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(true), // تأكيد الخروج
                child: Text("Exit"),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // ✅ منع الخروج بدون إرسال
      child: Scaffold(
        appBar: AppBar(
          title:
              Text("Survey Questions", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 28, 51, 95),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
        ),
        body: hasSubmitted
            ? Center(child: Text("You have already submitted this survey."))
            : _questions.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      LinearProgressIndicator(
                        value: _answers.length / _questions.length,
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _questions.length,
                          itemBuilder: (context, index) {
                            var question = _questions[index];

                            return Card(
                              margin: EdgeInsets.all(10),
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      question['title'] ?? 'Untitled Question',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 10),
                                    if (question['type'] == 'multiple_choice')
                                      Column(
                                        children: (question['options']
                                                as List<dynamic>)
                                            .map<Widget>(
                                                (option) => RadioListTile(
                                                      title: Text(option),
                                                      value: option,
                                                      groupValue: _answers[
                                                          question['title']],
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _answers[question[
                                                              'title']] = value;
                                                        });
                                                      },
                                                    ))
                                            .toList(),
                                      ),
                                    if (question['type'] == 'feedback')
                                      TextField(
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: "Enter your feedback...",
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _answers[question['title']] = value;
                                          });
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
        bottomNavigationBar: hasSubmitted
            ? null
            : Padding(
                padding: EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: _submitAnswers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(
                        255, 253, 200, 0), // Change background color
                    foregroundColor: Colors.black, // Change text color
                  ),
                  child: Text("Submit Answers"),
                ),
              ),
      ),
    );
  }
}

// ✅ شاشة الشكر بعد إرسال الاستبيان
class ThankYouPage extends StatelessWidget {
  final String studentId;
  final String studentGroup; // ✅ أضف studentGroup

  const ThankYouPage(
      {super.key,
      required this.studentId,
      required this.studentGroup}); // ✅ استقباله هنا

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thank You!")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            SizedBox(height: 20),
            Text(
              "Thank you for completing the survey!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentForm(
                      studentId: studentId,
                      studentGroup: studentGroup, // ✅ تمرير studentGroup هنا
                    ),
                  ),
                );
              },
              child: Text("Back to Available Surveys"),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavigationBarWidget extends StatelessWidget {
  final String studentId;
  final String studentGroup;

  const BottomNavigationBarWidget({
    super.key,
    required this.studentId,
    required this.studentGroup,
  });
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
            isSelected: true,
            onTap: () {
              Navigator.pushReplacementNamed(context, '/firsrforadminn');
            },
          ),
          BottomNavItem(
            icon: Icons.history, // Changed from edit to history
            label: "Survey History",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SurveyHistoryPage(
                    studentId: studentId,
                  ),
                ),
              );
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

class SurveyHistoryPage extends StatefulWidget {
  final String studentId;
  const SurveyHistoryPage({super.key, required this.studentId});
  @override
  _SurveyHistoryPageState createState() => _SurveyHistoryPageState();
}

class _SurveyHistoryPageState extends State<SurveyHistoryPage> {
  String? _editingResponseId;
  final Map<String, dynamic> _editedAnswers = {}; // Stores edited responses
  final Map<String, TextEditingController> _textControllers = {};

  @override
  void dispose() {
    _textControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _saveChanges(String responseId, List<dynamic> questions) async {
    final updates = <String, dynamic>{};

    // Combine edited answers from both text fields and multiple choice
    questions.forEach((question) {
      if (question['type'] == 'multiple_choice') {
        updates[question['title']] = _editedAnswers[question['title']];
      } else {
        updates[question['title']] =
            _textControllers['${responseId}${question['title']}']?.text;
      }
    });

    await FirebaseFirestore.instance
        .collection('students_responses')
        .doc(responseId)
        .update({'answers': updates});

    setState(() {
      _editingResponseId = null;
      _textControllers.forEach((key, value) => value.dispose());
      _textControllers.clear();
      _editedAnswers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Survey History")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('students_responses')
            .where('studentId', isEqualTo: widget.studentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var response = snapshot.data!.docs[index];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('surveys')
                    .doc(response['surveyId'])
                    .get(),
                builder: (context, surveySnapshot) {
                  if (!surveySnapshot.hasData) return Container();

                  var survey = surveySnapshot.data!;
                  final questions = survey['questions'] as List<dynamic>;
                  final answers = response['answers'] as Map<String, dynamic>;

                  return Card(
                    child: ExpansionTile(
                      title: Text(survey['name']),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Your Answers:",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              ...questions.map<Widget>((question) {
                                final answer = answers[question['title']];

                                // Initialize edited answers with current values
                                if (_editingResponseId == response.id) {
                                  if (question['type'] == 'multiple_choice') {
                                    _editedAnswers[question['title']] = answer;
                                  } else {
                                    final controllerKey =
                                        '${response.id}${question['title']}';
                                    if (!_textControllers
                                        .containsKey(controllerKey)) {
                                      _textControllers[controllerKey] =
                                          TextEditingController(text: answer);
                                    }
                                  }
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(question['title'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 5),
                                    _editingResponseId == response.id
                                        ? _buildEditableAnswer(question, answer)
                                        : Text(answer.toString()),
                                    SizedBox(height: 10),
                                  ],
                                );
                              }).toList(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (_editingResponseId == response.id)
                                    TextButton(
                                      onPressed: () async {
                                        await _saveChanges(
                                            response.id, questions);
                                      },
                                      child: Text('Save'),
                                    ),
                                  if (_editingResponseId == response.id)
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _editingResponseId = null;
                                          _textControllers.forEach(
                                              (key, value) => value.dispose());
                                          _textControllers.clear();
                                          _editedAnswers.clear();
                                        });
                                      },
                                      child: Text('Cancel'),
                                    ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _editingResponseId = response.id;
                                      });
                                    },
                                    child: Text('Edit'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('students_responses')
                                          .doc(response.id)
                                          .delete();
                                      setState(() {});
                                    },
                                    child: Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEditableAnswer(
      Map<String, dynamic> question, dynamic currentAnswer) {
    if (question['type'] == 'multiple_choice') {
      // Initialize edited answer if not already set
      if (_editingResponseId != null &&
          !_editedAnswers.containsKey(question['title'])) {
        _editedAnswers[question['title']] = currentAnswer;
      }

      return StatefulBuilder(
        builder: (context, setInnerState) {
          return Column(
            children: question['options'].map<Widget>((option) {
              return RadioListTile(
                title: Text(option),
                value: option,
                groupValue: _editedAnswers[question['title']],
                onChanged: (value) {
                  setInnerState(() {
                    _editedAnswers[question['title']] = value;
                  });
                },
                activeColor: Colors.blue,
              );
            }).toList(),
          );
        },
      );
    } else {
      final controllerKey = '${_editingResponseId}${question['title']}';
      return TextField(
        controller: _textControllers[controllerKey],
        decoration: InputDecoration(
          border: OutlineInputBorder(),
        ),
      );
    }
  }
}
