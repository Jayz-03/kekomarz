import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kekomarz/screens/auth/login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 200, 164, 212),
      body: Center(
        child: Image.asset(
          'assets/images/kekomarz-logo.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
