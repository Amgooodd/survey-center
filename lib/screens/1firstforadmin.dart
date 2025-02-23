import 'package:flutter/material.dart';

class firstforadmin extends StatefulWidget {
  const firstforadmin({super.key});

  @override
  _firstforadmin createState() => _firstforadmin();
}

class _firstforadmin extends State<firstforadmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Surveys',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/createsurvv');
                },
                child: Text('Create Survey',
                    style: TextStyle(color: Colors.white)),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/showsurvv');
                },
                child:
                    Text('Edit Survey', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/groupp');
            },
            child: Text('Your groups', style: TextStyle(color: Colors.white)),
          ),
          SizedBox(height: 40),
          SurveyCard(
              title: 'Spring Courses',
              subtitle: 'Stat 2025',
              image: "assets/exam3.png"),
          SurveyCard(
              title: 'Academic Advisors',
              subtitle: 'Chem 2025',
              image: 'assets/exam4.png'),
          SurveyCard(
              title: 'Biology Doctors',
              subtitle: 'Bio 2025',
              image: "assets/biotech.png"),
          SizedBox(height: 145),
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

class SurveyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;

  const SurveyCard(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 2),
          ],
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
                    Text(
                      title,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
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
              isSelected: true,
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
