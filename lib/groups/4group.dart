import 'package:flutter/material.dart';

class Group extends StatefulWidget {
  const Group({super.key});

  @override
  _Group createState() => _Group();
}

class _Group extends State<Group> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 50),
              Text(
                "Groups",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    SubjectCard(
                      title: "STAT/CS",
                      image: "assets/statistics.png",
                      onTap: () {
                        Navigator.pushNamed(context, '/statcs');
                      },
                    ),
                    SubjectCard(
                      title: "Chemistry",
                      image: "assets/chemistry.png",
                      onTap: () {
                        Navigator.pushNamed(context, '/chemistry');
                      },
                    ),
                    SubjectCard(
                      title: "Math/CS",
                      image: "assets/math.png",
                      onTap: () {
                        Navigator.pushNamed(context, '/mathcs');
                      },
                    ),
                    SubjectCard(
                      title: "Biotechnology",
                      image: "assets/biotech.png",
                      onTap: () {
                        Navigator.pushNamed(context, '/biotech');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavigationBarWidget(),
          ),
        ],
      ),
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
      height: 99,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 2),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BottomNavItem(
              icon: Icons.home,
              label: "Home",
              onTap: () {
                Navigator.pushReplacementNamed(context, '/firsrforadminn');
              }),
          BottomNavItem(
              icon: Icons.edit,
              label: "Create Survey",
              onTap: () {
                Navigator.pushReplacementNamed(context, '/createsurvv');
              }),
          BottomNavItem(
              icon: Icons.pie_chart,
              label: "Survey Results",
              onTap: () {
                Navigator.pushReplacementNamed(context, '/showsurvv');
              }),
          BottomNavItem(
              icon: Icons.group,
              label: "Groups",
              isSelected: true,
              onTap: () {
                Navigator.pushReplacementNamed(context, '/groupp');
              }),
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
                color: isSelected ? Colors.black : Colors.grey, size: 24),
            Text(
              label,
              style: TextStyle(
                  fontSize: 10, color: isSelected ? Colors.black : Colors.grey),
            ),
          ],
        ));
  }
}
