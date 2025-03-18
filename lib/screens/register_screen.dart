// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';
// import '../services/firestore_service.dart';
//
// class RegisterScreen extends StatefulWidget {
//   @override
//   _RegisterScreenState createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends State<RegisterScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final AuthService _authService = AuthService();
//   final FirestoreService _firestoreService = FirestoreService();
//
//   Future<void> _registerStudent() async {
//     String email = _emailController.text.trim();
//     String password = _passwordController.text.trim();
//     String name = _nameController.text.trim();
//
//     if (email.isEmpty || password.isEmpty || name.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text("Please fill out all fields."),
//       ));
//       return;
//     }
//
//     try {
//       var user = await _authService.register(email, password, 'student', name);
//       if (user != null) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text("Registration successful! Redirecting to dashboard..."),
//         ));
//         Navigator.pushReplacementNamed(context, '/studentDashboard',
//             arguments: user.uid);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text("Registration failed: $e"),
//       ));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Register as Student'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: InputDecoration(labelText: 'Full Name'),
//             ),
//             TextField(
//               controller: _emailController,
//               decoration: InputDecoration(labelText: 'Email'),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             TextField(
//               controller: _passwordController,
//               decoration: InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _registerStudent,
//               child: Text('Register'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
