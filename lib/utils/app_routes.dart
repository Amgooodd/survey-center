import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/first_image_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/forget_password_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => SplashScreen(),
    '/first': (context) => FirstImageScreen(),
    '/home': (context) => HomeScreen(),
    '/login': (context) => LoginScreen(),
    '/signup': (context) => SignUpScreen(),
    '/forgetpassword': (context) => ForgetPasswordScreen(),
  };
}
