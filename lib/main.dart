import 'package:faculty/mainlogin.dart';
import 'package:faculty/screens/faculty_dashboard.dart';
import 'package:faculty/screens/student_dashboard.dart';
import 'package:faculty/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import 'firebase_message.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessages firebaseMessages = FirebaseMessages();
  await firebaseMessages.initialize();// Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Faculty Availability App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
    );
  }
}
