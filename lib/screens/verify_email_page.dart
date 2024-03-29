import "dart:async";


import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:practice_project/screens/dashboard_screen.dart";

class VerifyEmailPage extends StatefulWidget{
  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {


  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState(){
    super.initState();

    try{

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
          Duration(seconds: 3), (_) => checkEmailVerified());
    }

    }
    catch (e){

    }
  }
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
    } catch (e) {}
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      timer?.cancel();
    }
  }
  @override
  Widget build(BuildContext context) => isEmailVerified
  ? DashboardScreen()
  : Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF9A69AB), // Dark Purple
              Color(0xFFC4A5E8), // Lighter Shade of Purple
              Color(0xFFFF6F61), // Contrasting Color
            ],
          ),
        ),
        child: Center(
          child: Text(
            'Please verify your email to access the dashboard.',
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      ),
    );
  
}