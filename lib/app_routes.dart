import 'package:flutter/material.dart';
import 'package:student_questionnaire/screens/AdminHome/admin_management.dart';
import 'package:student_questionnaire/screens/AdminHome/anal.dart';
import 'screens/AppStart/Splash_screen.dart';
import 'screens/AppStart/Welcome_screen.dart';
import 'deleted/Home_screen.dart';
import 'deleted/welcome_screen.dart';
import 'deleted/admin_login.dart';
import 'screens/AdminHome/admin_home.dart';
import 'screens/AdminHome/survey_create.dart';
import 'deleted/3showsurv.dart';
import 'screens/groups/groups_main.dart';
import 'screens/groups/groups_details.dart';
import 'screens/Auth/login_page.dart';
import 'package:student_questionnaire/deleted/student_login.dart' as login1;
import 'screens/AdminHome/surveys_analytics.dart';

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
    '/complog': (context) => CombinedLogin(),
    '/elanall': (context) => DataPage(),
    '/admin-management': (context) => AdminManagementScreen(currentAdminId: '',),
    '/welcome': (context) => WelcomeScreen(
        studentId: ModalRoute.of(context)!.settings.arguments as String),
    '/studentlogin': (context) => const login1.StudentLogin(),
      '/surveysanal': (context) => const SurveyAnalysisPage(surveyId: '',),
    '/groupDetails': (context) => GroupDetailsScreen(
          groupId: ModalRoute.of(context)!.settings.arguments as String,
        )
  };
}
