import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/first_image_screen.dart';
import '../screens/home_screen.dart';
import '../screens/admin_dashboard.dart';
import '../screens/welcome_screen.dart';
import '../screens/student_login.dart';
import '../screens/admin_login.dart';
import '../screens/1firstforadmin.dart';
import '../screens/2createsurv.dart';
import '../screens/3showsurv.dart';
import '../screens/4group.dart';
import '../screens/5uploaddata.dart';
import '../screens/6firstforstudent.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => SplashScreen(),
    '/first': (context) => FirstImageScreen(),
    '/home': (context) => HomeScreen(),
    '/adminlogin': (context) => AdminLogin(),
    '/admin_dashboard': (context) => AdminDashboard(),
    '/firsrforadminn': (context) => FirstForAdmin(),
    '/createsurvv': (context) => CreateSurvey(),
    '/showsurvv': (context) => showsurv(),
    '/groupp': (context) => group(),
    '/uploaddataa': (context) => uploaddata(),
    '/studentformm': (context) => studentform(),
    '/welcome': (context) => WelcomeScreen(
        studentId: ModalRoute.of(context)!.settings.arguments as String),
    '/studentlogin': (context) => StudentLogin(),
  };
}
