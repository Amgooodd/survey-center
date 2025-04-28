import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'survey_history.dart';
import 'dart:async';

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
  List<Map<String, dynamic>> _surveys = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchSurveys();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {});
    });
  }

  Future<void> _fetchSurveys() async {
    List<String> studentGroupComponents = widget.studentGroup
        .split('/')
        .map((e) => e.trim().toUpperCase())
        .toList();

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('surveys').get();

    setState(() {
      _surveys = snapshot.docs.where((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> surveyDepartments = data['departments'] ?? [];
        bool requireExact = data['require_exact_group_combination'] ?? false;
        bool showOnly = data['show_only_selected_departments'] ?? false;

        List<String> surveyDeptsUpper = surveyDepartments
            .map((dept) => dept.toString().trim().toUpperCase())
            .toList();

        if (surveyDeptsUpper.contains("ALL")) return true;

        if (requireExact) {
          List<String> sortedSurvey = List.from(surveyDeptsUpper)..sort();
          List<String> sortedStudent = List.from(studentGroupComponents)
            ..sort();
          return sortedSurvey.join('/') == sortedStudent.join('/');
        } else if (showOnly) {
          return studentGroupComponents.length == 1 &&
              surveyDeptsUpper.contains(studentGroupComponents[0]);
        } else {
          return surveyDeptsUpper
              .any((surveyDept) => studentGroupComponents.contains(surveyDept));
        }
      }).map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  void _clearFilter(String department) {
    setState(() {
      _selectedDepartments.remove(department);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home for Student", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 28, 51, 95),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/complog');
          },
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
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                  child: _surveys.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: _surveys.length,
                          itemBuilder: (context, index) {
                            var survey = _surveys[index];
                            DateTime? deadline = survey['deadline'] != null
                                ? (survey['deadline'] as Timestamp).toDate()
                                : null;
                            bool isExpired = deadline != null &&
                                deadline.isBefore(DateTime.now());
                            bool isFiltered = _selectedDepartments.isNotEmpty &&
                                !_selectedDepartments.contains(
                                    survey['departments'][0]
                                        .toString()
                                        .trim()
                                        .toUpperCase());
                            if (isFiltered) {
                              return SizedBox.shrink();
                            }
                            return Card(
                              margin: EdgeInsets.all(10),
                              child: ListTile(
                                title:
                                    Text(survey['name'] ?? 'Untitled Survey'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (survey['departments'] != null)
                                      Text(
                                        "Department(s): ${survey['departments'].join(', ')}",
                                      ),
                                    if (deadline != null)
                                      Text(
                                        "Deadline: ${DateFormat('yyyy-MM-dd HH:mm').format(deadline)}",
                                      ),
                                    if (isExpired)
                                      Text(
                                        "This survey has expired.",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                  ],
                                ),
                                trailing: isExpired
                                    ? null
                                    : ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Color.fromARGB(255, 253, 200, 0),
                                          foregroundColor: Colors.black,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SurveyQuestionsPage(
                                                studentId: widget.studentId,
                                                surveyId: survey['id'],
                                                studentGroup:
                                                    widget.studentGroup,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text("Start Survey"),
                                      ),
                              ),
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
  final String studentGroup;
  const SurveyQuestionsPage({
    super.key,
    required this.studentId,
    required this.surveyId,
    required this.studentGroup,
  });

  @override
  _SurveyQuestionsPageState createState() => _SurveyQuestionsPageState();
}

class _SurveyQuestionsPageState extends State<SurveyQuestionsPage> {
  bool hasSubmitted = false;
  List<Map<String, dynamic>> _questions = [];
  final Map<String, dynamic> _answers = {};
  bool _allowMultipleSubmissions = false;
  DateTime? _deadline;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _checkIfSubmitted();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_deadline != null && _deadline!.isBefore(DateTime.now())) {
        setState(() {});
      }
    });
  }

  Future<void> _submitAnswers() async {
    if (_answers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Please answer all questions before submitting.")),
      );
      return;
    }

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
    DocumentSnapshot surveySnapshot = await FirebaseFirestore.instance
        .collection('surveys')
        .doc(widget.surveyId)
        .get();
    if (!surveySnapshot.exists) return;
    setState(() {
      _allowMultipleSubmissions =
          surveySnapshot['allow_multiple_submissions'] ?? false;
      _deadline = surveySnapshot['deadline'] != null
          ? (surveySnapshot['deadline'] as Timestamp).toDate()
          : null;
    });
    if (!_allowMultipleSubmissions) {
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

  Future<bool> _onWillPop() async {
    if (hasSubmitted || _answers.isEmpty) {
      return true;
    }
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Exit Survey?"),
            content: Text("Your answers will not be saved. Are you sure?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Exit"),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    bool isExpired = _deadline != null && _deadline!.isBefore(DateTime.now());
    return WillPopScope(
      onWillPop: _onWillPop,
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
        body: isExpired
            ? Center(child: Text("This survey has expired."))
            : hasSubmitted
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          question['title'] ??
                                              'Untitled Question',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 10),
                                        if (question['type'] ==
                                            'multiple_choice')
                                          Column(
                                            children: (question['options']
                                                    as List<dynamic>)
                                                .map<Widget>((option) =>
                                                    RadioListTile(
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
                                        if (question['type'] == 'textfield')
                                          TextField(
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: "Enter your Answer...",
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                _answers[question['title']] =
                                                    value;
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
        bottomNavigationBar: isExpired
            ? null
            : hasSubmitted
                ? null
                : Padding(
                    padding: EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: _submitAnswers,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 253, 200, 0),
                        foregroundColor: Colors.black,
                      ),
                      child: Text("Submit Answers"),
                    ),
                  ),
      ),
    );
  }
}

class ThankYouPage extends StatelessWidget {
  final String studentId;
  final String studentGroup;
  const ThankYouPage(
      {super.key, required this.studentId, required this.studentGroup});

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
                      studentGroup: studentGroup,
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
            icon: Icons.history,
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
