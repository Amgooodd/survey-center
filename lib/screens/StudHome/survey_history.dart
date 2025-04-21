import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
