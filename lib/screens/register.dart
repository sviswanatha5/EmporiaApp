import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:practice_project/components/my_button.dart';
import 'package:practice_project/components/my_test_field.dart';
import 'package:practice_project/components/square_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:practice_project/services/aut_services.dart';

class RegisterScreen extends StatefulWidget {
  final Function()? onTap;
  const RegisterScreen({super.key, required this.onTap});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstNameController = TextEditingController();

  final lastNameController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  bool isEmailVerified = false;
  Timer? timer;

  //sign user
  void signUserUp() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    Navigator.pop(context);

    try {
      RegExp gatechEmailRegex = RegExp(r'@gatech\.edu$');
      bool endsWithGatechEmail =
          gatechEmailRegex.hasMatch(emailController.text.trim());

      if (!endsWithGatechEmail) {
        wrongInputMessage("Please use a @gatech.edu email");
      } else {
        if (passwordController.text == confirmPasswordController.text) {
          UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim());


          

        

          

          
            FirebaseAuth user = FirebaseAuth.instance;

            List<bool> preferences = List.generate(9, (index) => false);

            FirebaseFirestore.instance
                .collection('users')
                .doc(user.currentUser?.uid)
                .set({
              'uid': user.currentUser?.uid,
              'email': user.currentUser!.email,
              'preferences': preferences,
            });
          
          
        } else {
          //show error message that passwords aren't the same
          wrongInputMessage("Passwords don't match");
        }
      }
    } on FirebaseAuthException catch (exception) {
      wrongInputMessage(exception.toString());
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
/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //FlutterLogo(size: 100), // Temporary placeholder for logo
              // Make sure your logo is in the assets and properly linked in pubspec.yaml
              Image.asset('lib/images/logo.jpg', width: 150, height: 150),

              SizedBox(height: 24),

              Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                'Let\'s create an account',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),

              SizedBox(height: 30),

              // Firstname Input Field
              _buildInputField(
                icon: Icons.attribution,
                hintText: 'First Name',
                controller: firstNameController,
                obscureText: false,
              ),

              const SizedBox(height: 10),

              // Lastname Input Field
              _buildInputField(
                icon: Icons.attribution,
                hintText: 'Last Name',
                controller: lastNameController,
                obscureText: false,
              ),

              const SizedBox(height: 10),

              // Email Input Field
              _buildInputField(
                icon: Icons.email,
                hintText: 'Email',
                controller: emailController,
                obscureText: false,
              ),

              //password

              const SizedBox(height: 10),

              _buildInputField(
                icon: Icons.lock,
                hintText: 'Password',
                controller: passwordController,
                obscureText: true,
              ),

              const SizedBox(height: 10),

              //confirm password
              _buildInputField(
                icon: Icons.confirmation_num,
                hintText: 'Confirm Password',
                controller: confirmPasswordController,
                obscureText: true,
              ),

              const SizedBox(height: 10),

              // Sign In Button
              ElevatedButton(
                onPressed: signUserUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  shape: StadiumBorder(),
                  elevation: 5,
                ),
                child: Text(
                  'Sign In',
                  style: TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 30),

              // Google Sign-in Button

              const SizedBox(height: 15),

              // end of UI, asks for registration

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Already have an account? ',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: widget.onTap,
                  child: const Text(
                    'Login Now',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ])
            ],
          ),
        )),
      ),
    );
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: 30), // Adjust this padding as needed
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('lib/images/new_logo.jpg', width: 200, height: 200),
                Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Let\'s create an account',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 30),
                _buildInputField(
                  icon: Icons.attribution,
                  hintText: 'First Name',
                  controller: firstNameController,
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                _buildInputField(
                  icon: Icons.attribution,
                  hintText: 'Last Name',
                  controller: lastNameController,
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                _buildInputField(
                  icon: Icons.email,
                  hintText: 'Email',
                  controller: emailController,
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                _buildInputField(
                  icon: Icons.lock,
                  hintText: 'Password',
                  controller: passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                _buildInputField(
                  icon: Icons.confirmation_num,
                  hintText: 'Confirm Password',
                  controller: confirmPasswordController,
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed:
                      signUserUp, // Change this onPressed function as needed
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    shape: StadiumBorder(),
                    elevation: 5,
                  ),
                  child: Text(
                    'Sign In',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap:
                          widget.onTap, // Change this onTap function as needed
                      child: const Text(
                        'Login Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String hintText,
    required TextEditingController controller,
    required bool obscureText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white24,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
