import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isStudentLogin = true; // Toggle between student and faculty login

  @override
  void initState() {
    super.initState();
    _checkSavedCredentials();
  }

  Future<void> _checkSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? role = prefs.getString('role');


    if (email != null && role != null) {
      if (role == 'student') {
        Navigator.pushReplacementNamed(context, '/studentDashboard', arguments: email);
      } else if (role == 'faculty') {
        Navigator.pushReplacementNamed(context, '/facultyDashboard', arguments: email);
      }
    }
  }

  Future<void> _saveCredentials(String email, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('role', role);
    // await prefs.setString('name', name);
  }

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter both email and password."),
      ));
      return;
    }

    try {
      // Authenticate user
      User? user = await _authService.signIn(email, password);
      if (user != null) {
        // Get user role from Firestore
        String? role = await _firestoreService.getUserRole(user.uid);

        if (_isStudentLogin && role == 'student') {
          await _saveCredentials(email, 'student');
          Navigator.pushReplacementNamed(context, '/studentDashboard', arguments: user.uid);
        } else if (!_isStudentLogin && role == 'faculty') {
          await _saveCredentials(email, 'faculty');
          String facultyName = await _firestoreService.getFacultyName(user.uid); // Get faculty name
          Navigator.pushReplacementNamed(context, '/facultyDashboard', arguments: {
            'uid': user.uid,
             //'facultyName': facultyName,
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Invalid role for the selected login type."),
          ));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Login failed: $e"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _isStudentLogin ? 'Student Login' : 'Faculty Login',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
            if (_isStudentLogin)
              TextButton(
                onPressed: () {
                  // Navigate to register screen
                  Navigator.pushNamed(context, '/register');
                },
                child: Text('Register as Student'),
              ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isStudentLogin = !_isStudentLogin;
                });
              },
              child: Text(_isStudentLogin
                  ? 'Switch to Faculty Login'
                  : 'Switch to Student Login'),
            ),
          ],
        ),
      ),
    );
  }
}
