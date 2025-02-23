import 'package:flutter/material.dart';

class showsurv extends StatefulWidget {
  const showsurv({super.key});

  @override
  _showsurv createState() => _showsurv();
}

class _showsurv extends State<showsurv> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: 50),
          Center(
            child: Text(
              'Spring Courses',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: 390,
            height: 257,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/exam3.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          SurveyTable(),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () {},
            child: Text('download data', style: TextStyle(color: Colors.white)),
          ),
          SizedBox(height: 100),
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

class SurveyTable extends StatelessWidget {
  const SurveyTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 368,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFDEE1E6)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          SurveyRow(text: 'Question 1'),
          Divider(color: Color(0xFFDEE1E6)),
          SurveyRow(text: 'Question 2'),
          Divider(color: Color(0xFFDEE1E6)),
          SurveyRow(text: 'ETC'),
        ],
      ),
    );
  }
}

class SurveyRow extends StatelessWidget {
  final String text;
  const SurveyRow({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 18, color: Color(0xFF212121)),
          ),
          Row(
            children: [
              Icon(Icons.edit, size: 16, color: Colors.black54),
              SizedBox(width: 12),
              Icon(Icons.delete, size: 16, color: Colors.black54),
            ],
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
              isSelected: true,
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
