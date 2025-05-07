import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:student_questionnaire/screens/Auth/login_page.dart';
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
  List<Map<String, dynamic>> _notifications = [];
  late Timer _timer;
  String _selectedSortOption = 'newest';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchSurveys();
    _fetchNotifications();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {});
      _updateSurveyNotifications();
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
          if (surveyDeptsUpper.length == 2) {
            return studentGroupComponents
                .every((studentDept) => surveyDeptsUpper.contains(studentDept));
          } else {
            return surveyDeptsUpper.any(
                (surveyDept) => studentGroupComponents.contains(surveyDept));
          }
        }
      }).map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
      _surveys.sort((a, b) {
        switch (_selectedSortOption) {
          case 'newest':
            Timestamp aTime = a['timestamp'] ?? Timestamp.now();
            Timestamp bTime = b['timestamp'] ?? Timestamp.now();
            return bTime.compareTo(aTime);
          case 'oldest':
            Timestamp aTime = a['timestamp'] ?? Timestamp.now();
            Timestamp bTime = b['timestamp'] ?? Timestamp.now();
            return aTime.compareTo(bTime);
          case 'a-z':
            String aName = a['name']?.toString().toLowerCase() ?? '';
            String bName = b['name']?.toString().toLowerCase() ?? '';
            return aName.compareTo(bName);
          default:
            return 0;
        }
      });
    });
  }

  Future<void> _fetchNotifications() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('studentId', isEqualTo: widget.studentId)
        .where('isRead', isEqualTo: false)
        .get();
    setState(() {
      _notifications = snapshot.docs.map((doc) {
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

  void _markNotificationAsRead(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .delete();
    _fetchNotifications();
  }

  void _markAllNotificationsAsRead() async {
    for (var notification in _notifications) {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notification['id'])
          .delete();
    }
    _fetchNotifications();
  }

  Future<void> _updateSurveyNotifications() async {
    List<Map<String, dynamic>> newNotifications = [];
    List<String> notificationsToRemove = [];
    for (var survey in _surveys) {
      DateTime? deadline = survey['deadline'] != null
          ? (survey['deadline'] as Timestamp).toDate()
          : null;
      if (deadline != null) {
        final difference = deadline.difference(DateTime.now());
        if (difference.inHours < 1 && difference.inSeconds > 0) {
          bool isExistingNotification = _notifications.any((notification) =>
              notification['surveyId'] == survey['id'] &&
              notification['title'] == 'Survey About to End');
          if (!isExistingNotification) {
            newNotifications.add({
              'studentId': widget.studentId,
              'surveyId': survey['id'],
              'title': 'Survey About to End',
              'body': '${survey['name']} is closing soon!',
              'deadline': survey['deadline'],
              'createdAt': Timestamp.now(),
              'isRead': false,
            });
          }
        } else if (difference.inSeconds <= 0) {
          _notifications.forEach((notification) {
            if (notification['surveyId'] == survey['id'] &&
                (notification['title'] == 'Survey About to End' ||
                    notification['title'] == 'Survey Expired')) {
              notificationsToRemove.add(notification['id']);
            }
          });
        }
      }
    }
    for (var notification in newNotifications) {
      await FirebaseFirestore.instance
          .collection('notifications')
          .add(notification);
    }
    for (var notificationId in notificationsToRemove) {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .delete();
    }
    _fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 28, 51, 95),
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.red),
          onPressed: () async {
            bool? confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  "Confirm Logout",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  "Are you sure you want to log out?",
                  style: TextStyle(color: Colors.black),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      "Yes, Logout",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );

            // If user confirmed, proceed with logout
            if (confirmed == true) {
              logout(context);
            }
          },
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                color: Colors.white,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return NotificationsDialog(
                        notifications: _notifications,
                        markNotificationAsRead: _markNotificationAsRead,
                        markAllNotificationsAsRead: _markAllNotificationsAsRead,
                        studentId: widget.studentId,
                        studentGroup: widget.studentGroup,
                      );
                    },
                  );
                },
              ),
              if (_notifications.isNotEmpty)
                Positioned(
                  top: 5,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _notifications.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
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
                    SizedBox(height: 10),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.filter_list),
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
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => _clearFilter(department),
                        );
                      }).toList(),
                    ),
                  ),
                SizedBox(height: 10),
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('students')
                      .doc(widget.studentId)
                      .get(),
                  builder: (context, snapshot) {
                    String studentName = "Student";
                    if (snapshot.hasData && snapshot.data != null) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      studentName = data?['name'] ?? "Student";
                    }
                    return Text(
                      'Welcome $studentName',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 28, 51, 95),
                      ),
                    );
                  },
                ),
                SizedBox(height: 10),
                Container(
                  width: 350,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                    image: const DecorationImage(
                      image: AssetImage("assets/studentmain.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          'Your available surveys :',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 28, 51, 95),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 340,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 2.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 28, 51, 95),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          height: 40,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              DropdownButton<String>(
                                value: _selectedSortOption,
                                icon: const Icon(
                                  Icons.sort,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                underline: const SizedBox(),
                                dropdownColor:
                                    const Color.fromARGB(255, 28, 51, 95),
                                style: const TextStyle(color: Colors.white),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'newest',
                                    child: Text('Newest First'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'oldest',
                                    child: Text('Oldest First'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'a-z',
                                    child: Text('A-Z'),
                                  ),
                                ],
                                onChanged: (String? value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedSortOption = value;
                                      _fetchSurveys();
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: _surveys.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                itemCount: _surveys.length,
                                itemBuilder: (context, index) {
                                  var survey = _surveys[index];
                                  DateTime? deadline =
                                      survey['deadline'] != null
                                          ? (survey['deadline'] as Timestamp)
                                              .toDate()
                                          : null;
                                  bool isExpired = deadline != null &&
                                      deadline.isBefore(DateTime.now());
                                  bool isFilteredByDepartment =
                                      _selectedDepartments.isNotEmpty &&
                                          !_selectedDepartments.contains(
                                              survey['departments'][0]
                                                  .toString()
                                                  .trim()
                                                  .toUpperCase());
                                  bool matchesSearch = _searchQuery.isEmpty ||
                                      survey['name']
                                          .toString()
                                          .toLowerCase()
                                          .contains(_searchQuery);
                                  if (isFilteredByDepartment ||
                                      !matchesSearch) {
                                    return const SizedBox.shrink();
                                  }
                                  return Card(
                                    margin: const EdgeInsets.all(10),
                                    color: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.4),
                                            blurRadius: 5,
                                            spreadRadius: 2,
                                            offset: Offset(0, 2),
                                          )
                                        ],
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          survey['name'] ?? 'Untitled Survey',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: const Color.fromARGB(
                                                255, 28, 51, 95),
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (survey['departments'] != null)
                                              Text(
                                                "Department(s): ${survey['departments'].join(', ')}",
                                                style: TextStyle(
                                                  color: const Color.fromARGB(
                                                      255, 70, 94, 105),
                                                ),
                                              ),
                                            if (deadline != null)
                                              Text(
                                                "Deadline: ${DateFormat('yyyy-MM-dd HH:mm').format(deadline)}",
                                              ),
                                            if (isExpired)
                                              const Text(
                                                "This survey has expired.",
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                          ],
                                        ),
                                        trailing: isExpired
                                            ? null
                                            : ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 253, 200, 0),
                                                  foregroundColor: Colors.black,
                                                ),
                                                onPressed: () async {
                                                  final surveyId = survey['id'];
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                          'notifications')
                                                      .where('studentId',
                                                          isEqualTo:
                                                              widget.studentId)
                                                      .where('surveyId',
                                                          isEqualTo: surveyId)
                                                      .get()
                                                      .then((snapshot) {
                                                    for (var doc
                                                        in snapshot.docs) {
                                                      doc.reference.delete();
                                                    }
                                                  });

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SurveyQuestionsPage(
                                                        studentId:
                                                            widget.studentId,
                                                        surveyId: survey['id'],
                                                        studentGroup:
                                                            widget.studentGroup,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child:
                                                    const Text("Start Survey"),
                                              ),
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
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        studentId: widget.studentId,
        studentGroup: widget.studentGroup,
        homee: true,
      ),
    );
  }
}

class NotificationsDialog extends StatefulWidget {
  final List<Map<String, dynamic>> notifications;
  final Function(String) markNotificationAsRead;
  final Function() markAllNotificationsAsRead;
  final String studentId;
  final String studentGroup;
  const NotificationsDialog({
    super.key,
    required this.notifications,
    required this.markNotificationAsRead,
    required this.markAllNotificationsAsRead,
    required this.studentId,
    required this.studentGroup,
  });

  @override
  _NotificationsDialogState createState() => _NotificationsDialogState();
}

class _NotificationsDialogState extends State<NotificationsDialog> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _getRemainingTime(Timestamp? deadlineTimestamp) {
    if (deadlineTimestamp == null) return 'No deadline';
    final deadline = deadlineTimestamp.toDate();
    final now = DateTime.now();
    if (deadline.isBefore(now)) return 'Expired';
    final difference = deadline.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);
    return '${hours}h ${minutes}m ${seconds}s remaining';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.notifications_active, color: Colors.blue),
          SizedBox(width: 10),
          Text('Notifications'),
        ],
      ),
      content: widget.notifications.isNotEmpty
          ? SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.separated(
                itemCount: widget.notifications.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notification = widget.notifications[index];
                  final date =
                      (notification['createdAt'] as Timestamp).toDate();
                  final deadline = notification['deadline'] as Timestamp?;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: notification['title'] == 'Survey About to End'
                        ? const Icon(Icons.warning, color: Colors.red)
                        : const Icon(Icons.campaign, color: Colors.blue),
                    title: Text(
                      notification['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (notification['title'] == 'Survey About to End' &&
                            deadline != null)
                          Text(
                            'Time remaining: ${_getRemainingTime(deadline)}',
                            style: TextStyle(color: Colors.red),
                          ),
                        Text(notification['body']),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy - HH:mm').format(date),
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.done_all, color: Colors.green),
                      onPressed: () =>
                          widget.markNotificationAsRead(notification['id']),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SurveyQuestionsPage(
                            studentId: widget.studentId,
                            surveyId: notification['surveyId'],
                            studentGroup: widget.studentGroup,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          : const Center(child: Text('No new notifications')),
      actions: [
        TextButton(
          onPressed: widget.markAllNotificationsAsRead,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.done_all, color: Colors.green),
              SizedBox(width: 5),
              Text("Mark All as Read"),
            ],
          ),
        ),
      ],
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
        const SnackBar(
          content: Text("Please answer all questions before submitting."),
        ),
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
            title: const Text("Exit Survey?"),
            content:
                const Text("Your answers will not be saved. Are you sure?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Exit"),
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
          title: const Text(
            "Survey Questions",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 28, 51, 95),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
        ),
        body: isExpired
            ? const Center(child: Text("This survey has expired."))
            : hasSubmitted
                ? const Center(
                    child: Text("You have already submitted this survey."),
                  )
                : _questions.isEmpty
                    ? const Center(child: CircularProgressIndicator())
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
                                  margin: const EdgeInsets.all(10),
                                  color: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.4),
                                          blurRadius: 5,
                                          spreadRadius: 2,
                                          offset: Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            question['title'] ??
                                                'Untitled Question',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 10),
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
                                                                    'title']] =
                                                                value;
                                                          });
                                                        },
                                                      ))
                                                  .toList(),
                                            ),
                                          if (question['type'] == 'textfield')
                                            TextField(
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                hintText:
                                                    "Enter your Answer...",
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
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: _submitAnswers,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 253, 200, 0),
                        foregroundColor: Colors.black,
                      ),
                      child: const Text("Submit Answers"),
                    ),
                  ),
      ),
    );
  }
}

class ThankYouPage extends StatelessWidget {
  final String studentId;
  final String studentGroup;
  const ThankYouPage({
    super.key,
    required this.studentId,
    required this.studentGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Thank you ",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 28, 51, 95),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Color.fromARGB(255, 253, 200, 0),
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              "Thank you for completing the survey!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 28, 51, 95),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 253, 200, 0),
              ),
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
              child: const Text(
                "Back to Available Surveys",
                style: TextStyle(color: Colors.black),
              ),
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
  final bool homee;
  final bool hist;
  const BottomNavigationBarWidget({
    super.key,
    required this.studentId,
    required this.studentGroup,
    this.homee = false,
    this.hist = false,
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
            isSelected: homee,
            onTap: () {
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
          ),
          BottomNavItem(
            icon: Icons.history,
            label: "Survey History",
            isSelected: hist,
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
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.blueGrey,
            size: 24,
          ),
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
