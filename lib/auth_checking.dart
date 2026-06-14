import 'package:billing_software/employee/employee_dash.dart';
import 'package:billing_software/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'admin/admin_dashboard.dart';
import 'employee/employee_dashboard.dart';

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool _checking = true;
  Widget _nextScreen = LoginScreen();

  @override
  void initState() {
    _checkLogin();
    super.initState();
  }

  Future<void> _checkLogin() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (doc.exists) {
        final role = doc['role'];

        if (role == 'admin') {
          _nextScreen = AdminDashboard();
        } else {
          _nextScreen = EmployeeDashboardScreen();
        }
      }
    }

    setState(() {
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _checking
        ? Scaffold(body: Center(child: CircularProgressIndicator()))
        : _nextScreen;
  }
}
