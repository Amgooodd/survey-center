import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SurveyDetailsScreen extends StatefulWidget {
  final String surveyName;
  final List<Map<String, dynamic>> questions;

  const SurveyDetailsScreen({
    super.key,
    required this.surveyName,
    required this.questions,
  });

  @override
  _SurveyDetailsScreenState createState() => _SurveyDetailsScreenState();
}

class _SurveyDetailsScreenState extends State<SurveyDetailsScreen> {
  List<Map<String, dynamic>> _questions = [];
  int _questionCount = 1;

  @override
  void initState() {
    super.initState();
    _questions = widget.questions;
  }

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

  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _editQuestion(int index) {
    // Implement question editing logic here
  }

  void _deleteOption(Map<String, dynamic> question, String option) {
    setState(() {
      question['options'].remove(option);
    });
  }

  void _editOption(
      Map<String, dynamic> question, int optionIndex, String newValue) {
    setState(() {
      question['options'][optionIndex] = newValue;
    });
  }

  Future<void> _saveChanges(String surveyId) async {
    try {
      await FirebaseFirestore.instance
          .collection('surveys')
          .doc(surveyId)
          .update({
        'questions': _questions.map((q) => q).toList(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Changes saved successfully!")),
      );
    } catch (e) {
      print("Error saving changes: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save changes. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surveyName),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final question = _questions[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.list),
                      title: Text(question['title']),
                      subtitle: question['type'] == 'multiple_choice'
                          ? Column(
                              children: question['options']
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final optionIndex = entry.key;
                                final option = entry.value;
                                return Row(
                                  children: [
                                    Text(option),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        // Implement option editing logic here
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () =>
                                          _deleteOption(question, option),
                                    ),
                                  ],
                                );
                              }).toList(),
                            )
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editQuestion(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteQuestion(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => _addQuestion(false),
              child: Text('Add Question'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement download responses logic here
              },
              child: Text('Download Responses'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Save changes to Firestore
                // You need to pass the surveyId from the previous screen
                _saveChanges('surveys');
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
