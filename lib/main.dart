import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:student_questionnaire/Features/firebase_options.dart';
import 'app_routes.dart';
import 'providers/user_provider.dart';
import 'connectivity_service.dart'; 

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ConnectivityService _connectivityService = ConnectivityService();
  final _navigatorKey = GlobalKey<NavigatorState>(); 
  bool _isDialogVisible = false;

  @override
  void initState() {
    super.initState();
    _connectivityService.connectionStatus.listen((connected) {
      if (!connected) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_navigatorKey.currentState?.overlay != null && !_isDialogVisible) {
            _showNoInternetDialog();
          }
        });
      } else {
        _dismissDialog();
      }
    });
  }

  void _showNoInternetDialog() {
    _isDialogVisible = true;
    showDialog(
      context: _navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text('Please check your connection and try again.'),
          actions: [
            TextButton(
              onPressed: () async {
                final hasConnection = await _connectivityService.checkConnection();
                if (hasConnection) Navigator.pop(context);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    ).then((_) => _isDialogVisible = false);
  }

  void _dismissDialog() {
    if (_isDialogVisible) {
      Navigator.of(_navigatorKey.currentContext!).pop();
      _isDialogVisible = false;
    }
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Survey App',
        initialRoute: '/',
        routes: AppRoutes.routes,
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );
  runApp(const MyApp());
}