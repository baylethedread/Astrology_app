import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:astrology_ui/screens/welcome_screen.dart';
import 'package:astrology_ui/screens/home_screen.dart';
import 'package:astrology_ui/screens/profile_setup_screen.dart';

class Wrapper extends StatefulWidget {
  final Function(bool) toggleTheme;
  const Wrapper({super.key, required this.toggleTheme});

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  User? _user;
  bool _isLoading = true;
  bool _profileComplete = false;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      setState(() {
        _user = user;
        _isLoading = false;
      });

      if (user != null) {
        DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userDoc.exists && userDoc['profileComplete'] == true) {
          setState(() {
            _profileComplete = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_user == null) {
      return WelcomeScreen(toggleTheme: widget.toggleTheme);
    } else if (!_profileComplete) {
      return ProfileSetupScreen();
    } else {
      return HomeScreen(toggleTheme: widget.toggleTheme);
    }
  }
}
