import 'package:flutter/material.dart';
import 'utils/app_routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Survey App',
      initialRoute: '/',
      routes: AppRoutes.routes, // استخدام ملف التنقل بين الشاشات
    );
  }
}
