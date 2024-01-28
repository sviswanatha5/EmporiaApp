import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:practice_project/screens/first_screen.dart";
import "package:practice_project/screens/home_screen.dart";

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return const FirstScreen();
              } else {
                return HomeScreen();
              }
            }));
  }
}