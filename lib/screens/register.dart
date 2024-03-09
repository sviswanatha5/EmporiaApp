import 'package:cloud_firestore/cloud_firestore.dart';
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
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

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
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text.trim(), password: passwordController.text.trim());

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
        child: SafeArea(
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

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.white,
                        thickness: 0.5,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'OR CONTINUE WITH',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.white,
                        thickness: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // For google sign in

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SquareTile(
                    imagePath: 'lib/images/google.png',
                    onTap: () => AuthService().signInGoogle()),
              ]),

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
