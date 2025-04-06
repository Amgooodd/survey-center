import 'package:flutter/material.dart';
import 'package:student_questionnaire/screens/addexel.dart';

class Group extends StatefulWidget {
  const Group({super.key});

  @override
  _Group createState() => _Group();
}

class _Group extends State<Group> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Groups", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 28, 51, 95),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 70),
              Expanded(
                child: GridView.count(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    SubjectCard(
                      title: "STAT/CS",
                      image: "assets/stat_cs.png",
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/groupDetails',
                          arguments: "STAT/CS",
                        );
                      },
                    ),
                    SubjectCard(
                      title: "Math/CS",
                      image: "assets/math_cs.png",
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/groupDetails',
                          arguments: "Math/CS",
                        );
                      },
                    ),
                    SubjectCard(
                      title: "Chemistry",
                      image: "assets/chemistry.png",
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/groupDetails',
                          arguments: "Chemistry",
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 253, 200, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () {
                            FileUploader().pickFile(context);
                          },
                          child: Row(
                            children: [
                              Icon(Icons.person_add_alt_1, color: Colors.black),
                              Text(' Add students ',
                                  style: TextStyle(color: Colors.black)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 40),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(),
    );
  }
}

class SubjectCard extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const SubjectCard({
    super.key,
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: onTap,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(image),
            ),
          )
        ],
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
            onTap: () {
              Navigator.pushReplacementNamed(context, '/firsrforadminn');
            },
          ),
          BottomNavItem(
            icon: Icons.edit,
            label: "Create Survey",
            onTap: () {
              Navigator.pushReplacementNamed(context, '/createsurvv');
            },
          ),
          BottomNavItem(
            icon: Icons.group,
            label: "Groups",
            isSelected: true,
            onTap: () {
              Navigator.pushReplacementNamed(context, '/groupp');
            },
          ),
          BottomNavItem(
            icon: Icons.navigate_next,
            label: "Add Student",
            onTap: () {
              Navigator.pushNamed(context, '/admin_dashboard');
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
