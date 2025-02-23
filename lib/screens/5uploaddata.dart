import 'package:flutter/material.dart';

class uploaddata extends StatefulWidget {
  const uploaddata({super.key});

  @override
  _uploaddata createState() => _uploaddata();
}

class _uploaddata extends State<uploaddata> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: 390,
            height: 962,
            color: Colors.white,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 390,
              height: 99,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 52,
            left: 20,
            child: SizedBox(
              width: 350,
              height: 36,
              child: Text(
                "Groups",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned(
            top: 398,
            left: 0,
            child: Container(
              width: 390,
              height: 97,
              color: Colors.white,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Upload new students",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "The file should be Excel or CSV file only.",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 530,
            left: 220,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                minimumSize: Size(150, 36),
              ),
              onPressed: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 16),
                  SizedBox(width: 5),
                  Text("Upload", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
          Positioned(
            top: 158,
            left: 0,
            child: Container(
              width: 390,
              height: 257,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 350,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                      image: DecorationImage(
                        image: AssetImage("assets/statistics.png"),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "STAT / CS",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavigationBarWidget(),
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
