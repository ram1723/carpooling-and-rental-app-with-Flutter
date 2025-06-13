import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  Future<Widget> _determineStartPage() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginRedirect();
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      return const HomeRedirect();
    } else {
      return const SignupRedirect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _determineStartPage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.data ?? const LoginRedirect();
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

// Redirect Widgets
class LoginRedirect extends StatelessWidget {
  const LoginRedirect({super.key});
  @override
  Widget build(BuildContext context) {
    Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
    return const SizedBox();
  }
}

class SignupRedirect extends StatelessWidget {
  const SignupRedirect({super.key});
  @override
  Widget build(BuildContext context) {
    Future.microtask(() => Navigator.pushReplacementNamed(context, '/signup'));
    return const SizedBox();
  }
}

class HomeRedirect extends StatelessWidget {
  const HomeRedirect({super.key});
  @override
  Widget build(BuildContext context) {
    Future.microtask(() => Navigator.pushReplacementNamed(context, '/home'));
    return const SizedBox();
  }
}
