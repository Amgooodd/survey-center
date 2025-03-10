import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/first_image_screen.dart';
import '../screens/home_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/student_login.dart';
import '../screens/admin_login.dart';
import '../screens/1firstforadmin.dart';
import '../screens/2createsurv.dart';
import '../screens/3showsurv.dart';
import '../groups/4group.dart';
import '../groups/UploadData.dart';
import 'package:student_questionnaire/screens/student_login.dart' as login1;

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => SplashScreen(),
    '/first': (context) => FirstImageScreen(),
    '/home': (context) => HomeScreen(),
    '/adminlogin': (context) => AdminLogin(),
    '/firsrforadminn': (context) => FirstForAdmin(),
    '/createsurvv': (context) => CreateSurvey(),
    '/showsurvv': (context) => showsurv(),
    '/groupp': (context) => Group(),
    '/welcome': (context) => WelcomeScreen(
        studentId: ModalRoute.of(context)!.settings.arguments as String),
    '/studentlogin': (context) => const login1.StudentLogin(),

    // ignore: equal_keys_in_map
    '/groupp': (context) => Group(),
    '/groupDetails': (context) => GroupDetailsScreen(
          groupId: ModalRoute.of(context)!.settings.arguments as String,
        )
  };
}
