import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentForm extends StatefulWidget {
  final String studentId;
  final String studentGroup; // ✅ تأكد أنه يتم استقباله

  const StudentForm({
    super.key,
    required this.studentId,
    required this.studentGroup,
  });

  @override
  _StudentFormState createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  late Stream<List<DocumentSnapshot>> _surveysStream;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
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
      return departments.every(
        (dept) =>
            groupComponents.contains(dept.toString().trim().toUpperCase()),
      );
    }).map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
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
                              setState(() {
                                _searchQuery = value.toLowerCase();
                              });
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
      bottomNavigationBar: BottomNavigationBarWidget(),
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
            isSelected: true,
            onTap: () {
              Navigator.pushReplacementNamed(context, '/firsrforadminn');
            },
          ),
          BottomNavItem(
            icon: Icons.edit,
            label: "Survey history",
            onTap: () {
              Navigator.pushReplacementNamed(context, '/createsurvv');
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
