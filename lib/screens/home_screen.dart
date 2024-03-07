import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:practice_project/components/my_button.dart';
import 'package:practice_project/components/my_test_field.dart';
import 'package:practice_project/components/square_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:practice_project/services/aut_services.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';


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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.deepPurple.shade700,
              Colors.deepPurple.shade500,
              Colors.deepPurple.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),

                //FlutterLogo(size: 100), // Temporary placeholder for logo
                // Make sure your logo is in the assets and properly linked in pubspec.yaml
                Image.asset('lib/images/logo.jpg', width: 150, height: 150),

                SizedBox(height: 24),

                Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  'Log in to your account',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),

                SizedBox(height: 48),

                // Email Input Field
                _buildInputField(
                  icon: Icons.email,
                  hintText: 'Email',
                  controller: emailController,
                  obscureText: false,
                ),

                SizedBox(height: 16),

                // Password Input Field
                _buildInputField(
                  icon: Icons.lock,
                  hintText: 'Password',
                  controller: passwordController,
                  obscureText: true,
                ),

                SizedBox(height: 24),

                // Sign In Button
                ElevatedButton(
                  onPressed: signUserIn,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.purple,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    shape: StadiumBorder(),
                    elevation: 5,
                  ),
                  child: Text('Sign In', style: TextStyle(color: Colors.white), ),
                ),

                Spacer(),

                                // Google Sign-in Button
                // Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                // SquareTile(
                //   imagePath: 'lib/images/google.png', 
                //   onTap: () => AuthService().signInGoogle(),
                //   ),
                // ]),

                // Google Sign-in Button
                SignInButton(
                  Buttons.Google,
                  text: "Sign in with Google",
                  onPressed: () async {
                    try {
                      await AuthService().signInGoogle();
                    } catch (e) {
                      wrongInputMessage(e.toString());
                    }
                  },
                ),


                Spacer(),

                // Registration prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(color: Colors.white70),
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        ' Register Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),
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