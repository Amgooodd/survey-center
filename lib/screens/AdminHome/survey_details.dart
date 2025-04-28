import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_questionnaire/Features/download_excel.dart';

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
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Subtitle: ${data['subtitle']?.toString() ?? 'No Subtitle'}'),
                Text('Departments: $departments'),
                Text('Created At: $formattedTime'),
                SizedBox(height: 20),
                Text('Questions:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                ElevatedButton(
                  onPressed: () async {
                    await SurveyExporter()
                        .exportSurveyResponses(widget.survey.id);
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text('Downoad responses',
                      style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _showDeleteConfirmation,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('Delete Survey',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddQuestionTypeDialog,
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}
