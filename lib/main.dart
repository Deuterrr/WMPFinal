import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'login_screen.dart';
import 'subjects_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Enrollment App',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/subjects': (context) => SubjectsScreen(),
      },
    );
  }
}
