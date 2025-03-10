import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentLogin extends StatefulWidget {
  @override
  _StudentLoginState createState() => _StudentLoginState();
}

class _StudentLoginState extends State<StudentLogin> {
  final TextEditingController _idController = TextEditingController();

  Future<void> _validateStudentId() async {
    String id = _idController.text.trim();
    if (id.isEmpty) return;

    final DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('students').doc(id).get();

    if (snapshot.exists) {
      String studentGroup = snapshot.get('group');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StudentForm(
            studentId: id,
            studentGroup: studentGroup,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid student ID. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Student Login")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: "Enter Student ID"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _validateStudentId,
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentForm extends StatefulWidget {
  final String studentId;
  final String studentGroup; // ✅ تأكد أنه يتم استقباله

  StudentForm({
    Key? key,
    required this.studentId,
    required this.studentGroup,
  }) : super(key: key);

  @override
  _StudentFormState createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  Future<List<Map<String, dynamic>>> getSurveys() async {
    List<String> groupComponents = widget.studentGroup
        .split('/')
        .map((e) => e.trim().toUpperCase())
        .toList();

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('surveys').get();

    return snapshot.docs.where((doc) {
      List<dynamic> departments = (doc.data() as Map)['departments'] ?? [];
      return departments.any(
        (dept) =>
            groupComponents.contains(dept.toString().trim().toUpperCase()),
      );
    }).map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Available Surveys")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getSurveys(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No surveys available for your group."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var survey = snapshot.data![index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(survey['name'] ?? 'Untitled Survey'),
                  subtitle: Text(survey['description'] ?? 'No description'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SurveyQuestionsPage(
                            studentId: widget.studentId,
                            surveyId: survey['id'],
                            studentGroup:
                                widget.studentGroup, // ✅ تمرير studentGroup هنا
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
    );
  }
}

class SurveyQuestionsPage extends StatefulWidget {
  final String studentId;
  final String surveyId;
  final String studentGroup; // ✅ أضف studentGroup هنا

  SurveyQuestionsPage({
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
  Map<String, dynamic> _answers = {};

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

    await FirebaseFirestore.instance
        .collection('students_responses')
        .doc("${widget.surveyId}_${widget.studentId}")
        .set({
      'studentId': widget.studentId,
      'surveyId': widget.surveyId,
      'answers': _answers,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      hasSubmitted = true;
    });

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
    DocumentSnapshot response = await FirebaseFirestore.instance
        .collection('students_responses')
        .doc("${widget.surveyId}_${widget.studentId}")
        .get();

    if (response.exists) {
      setState(() {
        hasSubmitted = true;
      });
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
    if (hasSubmitted || _answers.isEmpty)
      return true; // خروج عادي إذا تم الإرسال

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
        appBar: AppBar(title: Text("Survey Questions")),
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

  ThankYouPage(
      {required this.studentId, required this.studentGroup}); // ✅ استقباله هنا

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
