import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/faculty_dashboard.dart';

class FacultyLoginScreen extends StatefulWidget {
  @override
  _FacultyLoginScreenState createState() => _FacultyLoginScreenState();
}

class _FacultyLoginScreenState extends State<FacultyLoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Hardcoded list of faculty email IDs
  final List<String> facultyEmails = [
    "debasishmishra@giet.edu",
    "anotherfaculty@giet.edu",
    "debasishmishra9876@gmail.com",
    "abhishekpradhan@giet.edu",
    "ajitpatro@giet.edu",
    "ajits@giet.edu",
    "aksamal@giet.edu",
    "akshyasahoo@giet.edu",
    "amiparida@giet.edu",
    "amlanasutosh@giet.edu",
    "anmolgiri@giet.edu",
    "anmolpanda@giet.edu",
    "aparnababoo@giet.edu",
    "aparnayerra@giet.edu",
  ];

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null && facultyEmails.contains(user.email)) {
        String facultyName = user.email!.split('@')[0];
        String profileImageUrl = user.photoURL ?? "";
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', user.email!);
        await prefs.setString('role', 'faculty');
        await prefs.setString('facultyName', facultyName);
        await prefs.setString('profileImage', profileImageUrl);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FacultyDashboard()),
        );
      } else {
        await GoogleSignIn().signOut();
        _showError("Access denied. You are not a registered faculty.");
      }
    } catch (e) {
      _showError("Login failed: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/back3.jpeg', // Replace with your image
              fit: BoxFit.cover,
            ),
          ),
          // Login Form
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              width: 350,
              child: ElevatedButton(
                onPressed: _signInWithGoogle,
                child: Text("Do Faculty Log IN"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
