

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

Future<void> _deleteAllInCollection(String collectionName) async {
  final collection = FirebaseFirestore.instance.collection(collectionName);
  final snapshot = await collection.get();
  for (var doc in snapshot.docs) {
    await doc.reference.delete();
  }
}


Future<void> _resetAllSurveys() async {
  try {
    await _deleteAllInCollection('surveys');
    await _deleteAllInCollection('notifications');
    await _deleteAllInCollection('students_responses');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("All surveys and related data deleted")),
    );
  } catch (e) {
    print("Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to reset surveys: $e")),
    );
  }
}


Future<void> _deleteAllStudents() async {
  try {
    await _deleteAllInCollection('students');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("All student data deleted")),
    );
  } catch (e) {
    print("Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to delete students: $e")),
    );
  }
}


Future<void> _resetEverything() async {
  try {
    await _deleteAllInCollection('surveys');
    await _deleteAllInCollection('notifications');
    await _deleteAllInCollection('students_responses');
    await _deleteAllInCollection('students');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("All data reset except admins")),
    );
  } catch (e) {
    print("Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Reset failed: $e")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bool isSuperAdmin = (args?['isSuperAdmin'] as bool?) ?? false;
    return Scaffold(
      appBar: AppBar(
        title: Text(isSuperAdmin ? "Home for Super Admin" : "Home for Admin",
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 28, 51, 95),
        leading: IconButton(
          icon: Icon(Icons.logout, color: Colors.red),
          onPressed: () => logout(context),
        ),
        centerTitle: true,
         actions: isSuperAdmin 
    ? [
        PopupMenuButton<String>(
          icon: Icon(Icons.settings),
          onSelected: (value) async {
  bool? confirmedFirst = false;
  bool? confirmedSecond = false;
  bool? confirmedThird = false;
  switch (value) {
    case 'reset_surveys':
      
      confirmedFirst = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("First Warning"),
          content: Text("This will delete all surveys, notifications, and responses. Continue?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Yes"),
            ),
          ],
        ),
      );
      if (confirmedFirst != null && confirmedFirst) {
        
        confirmedSecond = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Second Warning"),
            content: Text("Are you sure? This action cannot be undone."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Yes"),
              ),
            ],
          ),
        );
        if (confirmedSecond != null && confirmedSecond) {
          
          confirmedThird = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Final Warning"),
              content: Text("LAST CHANCE: Proceed with deleting all surveys and related data?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text("Proceed"),
                ),
              ],
            ),
          );
          if (confirmedThird != null && confirmedThird) {
            await _resetAllSurveys(); 
          }
        }
      }
      break;
    case 'delete_students':
      
      confirmedFirst = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("First Warning"),
          content: Text("This will delete all student data. Continue?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Yes"),
            ),
          ],
        ),
      );
      if (confirmedFirst != null && confirmedFirst) {
        
        confirmedSecond = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Second Warning"),
            content: Text("Are you sure? This action cannot be undone."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Yes"),
              ),
            ],
          ),
        );
        if (confirmedSecond != null && confirmedSecond) {
          
          confirmedThird = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Final Warning"),
              content: Text("LAST CHANCE: Proceed with deleting all student data?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text("Proceed"),
                ),
              ],
            ),
          );
          if (confirmedThird != null && confirmedThird) {
            await _deleteAllStudents(); 
          }
        }
      }
      break;
    case 'reset_all':
      
      confirmedFirst = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("First Warning"),
          content: Text("This will delete all data except admins. Continue?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Yes"),
            ),
          ],
        ),
      );
      if (confirmedFirst != null && confirmedFirst) {
        
        confirmedSecond = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Second Warning"),
            content: Text("Are you sure? This action cannot be undone."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Yes"),
              ),
            ],
          ),
        );
        if (confirmedSecond != null && confirmedSecond) {
          
          confirmedThird = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Final Warning"),
              content: Text("LAST CHANCE: Proceed with deleting all data except admins?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text("Proceed"),
                ),
              ],
            ),
          );
          if (confirmedThird != null && confirmedThird) {
            await _resetEverything(); 
          }
        }
      }
      break;
  }
},
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'reset_surveys',
              child: Text("Reset All Surveys"),
            ),
            PopupMenuItem(
              value: 'delete_students',
              child: Text("Delete All Students"),
            ),
            PopupMenuItem(
              value: 'reset_all',
              child: Text("Reset Everything"),
            ),
          ],
        ),
      ]
    : [], 
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (isSuperAdmin)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Super Admin Controls',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
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
                          if (!isSuperAdmin) {
                            
                            return createdBy == currentUserId &&
                                name.contains(_searchQuery) &&
                                (_selectedDepartments.isEmpty ||
                                    _selectedDepartments.every((dep) =>
                                        departments
                                            .contains(dep.toLowerCase())));
                          } else {
                            
                            return name.contains(_searchQuery) &&
                                (_selectedDepartments.isEmpty ||
                                    _selectedDepartments.every((dep) =>
                                        departments
                                            .contains(dep.toLowerCase())));
                          }
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
  Future<int> _getResponseCount() async {
    final query = await FirebaseFirestore.instance
        .collection('students_responses')
        .where('surveyId', isEqualTo: survey.id)
        .get();
    return query.size;
  }
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                        FutureBuilder<int>(
                          future: _getResponseCount(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              );
                            }
                            if (snapshot.hasError) return const Text('?');
                            return Text(
                              '(${snapshot.data ?? 0} responses)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ],
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

