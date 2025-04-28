import 'package:flutter/material.dart';
import 'package:student_questionnaire/widgets/cardanal.dart';
import '../../widgets/Bottom_bar.dart';

class anall extends StatefulWidget {
  const anall({super.key});

  @override
  _anall createState() => _anall();
}

class _anall extends State<anall> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Analyitics", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 28, 51, 95),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/firsrforadminn');
          },
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    ActiveUsersCard(activeUsers: 27, totalUsers: 80),
                    ActiveUsersCard(activeUsers: 27, totalUsers: 80),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        anall: true,
      ),
    );
  }
}




/*onPressed: () {
                            FileUploader().pickFile(context);
                          },*/