import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:practice_project/components/my_button.dart';
import 'package:practice_project/components/my_test_field.dart';
import 'package:practice_project/components/square_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:practice_project/services/aut_services.dart';

class HomeScreen extends StatefulWidget {
  final Function()? onTap;
  const HomeScreen({super.key, required this.onTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  //sign user
  void signUserIn() async {
    //Navigator.pop(context);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      FirebaseAuth user = FirebaseAuth.instance;

      FirebaseFirestore.instance
            .collection('users')
            .doc(user.currentUser?.uid)
            .set({
          'uid': user.currentUser?.uid,
          'email': user.currentUser!.email,
        }, SetOptions(merge: true));

    } on FirebaseAuthException catch (exception) {
      wrongInputMessage("Wrong email or password");
    }
  }

  void wrongInputMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(message),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
            child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),

              //logo

              const Icon(
                Icons.lock,
                size: 100,
              ),

              const SizedBox(height: 50),

              const Text(
                'Welcome back!',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              //username

              MyTextField(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),

              //password

              const SizedBox(height: 10),

              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,

                
              ),

              const SizedBox(height: 25),

              MyButton(onTap: () => {signUserIn()}, text: "Sign In"),

              const SizedBox(height: 25),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.black,
                        thickness: 0.5,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Or continue with',
                        style:
                            TextStyle(color: Colors.black),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.black,
                        thickness: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // For google sign in

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SquareTile(
                  imagePath: 'lib/images/google.png', 
                  onTap: () => AuthService().signInGoogle(),
                  ),
              ]),

              const SizedBox(height: 30),

              // end of UI, asks for registration
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Not a member? ',
                    style: TextStyle(color: Colors.black)),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: widget.onTap,
                  child: const Text(
                    'Register Now',
                    style: TextStyle(
                        color: Color.fromARGB(255, 55, 4, 77),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ])
            ],
          ),
        )),
      ),
    );
  }
}
