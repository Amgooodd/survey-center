import 'package:flutter/material.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final bool homee;
  final bool isSuperAdmin;
  final bool survv;
  final bool groupp;
  final bool anall;

  const BottomNavigationBarWidget({
    super.key,
    this.homee = false,
    this.isSuperAdmin = false,
    this.survv = false,
    this.groupp = false,
    this.anall = false,
  });

  @override
  Widget build(BuildContext context) {
    int currentIndex;
    if (isSuperAdmin) {
      if (homee) currentIndex = 1;
      else if (survv) currentIndex = 2;
      else if (groupp) currentIndex = 3;
      else if (anall) currentIndex = 4;
      else currentIndex = 0; 
    } else {
      if (homee) currentIndex = 0;
      else if (survv) currentIndex = 1;
      else if (groupp) currentIndex = 2;
      else if (anall) currentIndex = 3;
      else currentIndex = 0;
    }

    return BottomNavigationBar(
      items: [
        if (isSuperAdmin)
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Add Admins',
          ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.edit),
          label: 'Create Survey',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Groups',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
      ],
      currentIndex: currentIndex,
      onTap: (index) {
        if (isSuperAdmin) {
          
          switch (index) {
            case 0:
              
              Navigator.pushNamed(context, '/admin-management');
              break;
            case 1:
              
              Navigator.popUntil(
                context,
                (route) => route.settings.name == '/firsrforadminn',
              );
              break;
            case 2:
              Navigator.pushNamed(context, '/createsurvv');
              break;
            case 3:
              Navigator.pushNamed(context, '/groupp');
              break;
            case 4:
              Navigator.pushNamed(context, '/elanall');
              break;
          }
        } else {
          
          switch (index) {
            case 0:
              
              Navigator.popUntil(
                context,
                (route) => route.settings.name == '/firsrforadminn',
              );
              break;
            case 1:
              Navigator.pushNamed(context, '/createsurvv');
              break;
            case 2:
              Navigator.pushNamed(context, '/groupp');
              break;
            case 3:
              Navigator.pushNamed(context, '/elanall');
              break;
          }
        }
      },
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
    );
  }
}