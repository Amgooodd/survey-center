import 'package:flutter/material.dart';

class createsurv extends StatefulWidget {
  const createsurv({super.key});

  @override
  _createsurv createState() => _createsurv();
}

class _createsurv extends State<createsurv> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Create Survey",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create survey Name",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter survey name",
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Upload survey photo",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child:
                  Text("Browse files", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 30),
            Text(
              "Create survey Questions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 20),
            Text(
              "Question 1",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
                hintText: "Enter the question ",
              ),
            ),
            SizedBox(height: 20),
            Column(
              children: [
                RadioListTile(
                  title: Text("Yes"),
                  value: "yes",
                  groupValue: null,
                  onChanged: (value) {},
                ),
                RadioListTile(
                  title: Text("No"),
                  value: "no",
                  groupValue: null,
                  onChanged: (value) {},
                ),
                RadioListTile(
                  title: Text("Maybe"),
                  value: "maybe",
                  groupValue: null,
                  onChanged: (value) {},
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text("Add Question",
                      style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text("Finish the survey",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavigationBarWidget(),
            )
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
              onTap: () {
                Navigator.pushReplacementNamed(context, '/firsrforadminn');
              }),
          BottomNavItem(
              icon: Icons.edit,
              label: "Create Survey",
              isSelected: true,
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
