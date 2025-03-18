import 'package:faculty/screens/faculty_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:faculty/screens/student_dashboard.dart';
import 'package:faculty/screens/login_screen.dart';
import 'faculty_login.dart';
import 'mainlogin.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(_controller);

    // Initialize Video Player
    _videoController = VideoPlayerController.asset('assets/images/splash.mp4')
      ..initialize().then((_) {
        setState(() {}); // Ensure the first frame is shown
        _videoController.setLooping(true);
        _videoController.play();
      });

    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('email');
    final String? role = prefs.getString('role');

    await Future.delayed(Duration(seconds: 6)); // Adjusted to your video length

    if (email != null && role != null) {
      if (role == 'faculty') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FacultyDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StudentDashboard()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainLoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Video
          Positioned.fill(
            child: _videoController.value.isInitialized
                ? VideoPlayer(_videoController)
                : Container(color: Colors.black),
          ),
          // Animated Text
          Center(
            child: FadeTransition(
              opacity: _animation,
              child: Text(
                "Know your Faculty Status !!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
