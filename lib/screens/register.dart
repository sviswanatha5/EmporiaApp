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
            email: emailController.text, password: passwordController.text);

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
      //Navigator.pop(context);
      if (exception.code == 'auth/user-not-found') {
        //print('No user found/ wrong email');

        wrongInputMessage("Wrong email");
      } else if (exception.code == 'auth/wrong-password') {
        //print('Wrong password');

        wrongInputMessage("Wrong password");
      } else {
        wrongInputMessage("Wrong email or password");
      }
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
                'Let\'s create an account',
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
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration( // Add some styling to input decoration
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Email',
                  ),
                ),

              //password

              const SizedBox(height: 10),

                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration( // Add some styling to input decoration
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Password',
                  ),
                ),

              const SizedBox(height: 10),

              //confirm password
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration( // Add some styling to input decoration
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Confirm Password',
                  ),
                ),


              const SizedBox(height: 25),
                MyButton(
                  //onTap: () => {signUserUp()}
                  onTap: signUserUp,
                  text: "Sign Up",
                  color: Colors.purple,
                  textColor: Colors.white,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.purpleAccent),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 16.0),
                    ),
                  ),
                ),
              const SizedBox(height: 30),

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
                        style: TextStyle(color: Colors.black),
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

              const SizedBox(height: 15),

              // For google sign in

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SquareTile(
                    imagePath: 'lib/images/google.png',
                    onTap: () => AuthService().signInGoogle()),
              ]),

              const SizedBox(height: 15),

              // end of UI, asks for registration
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Already have an account? ',
                    style: TextStyle(color: Colors.black)),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: widget.onTap,
                  child: const Text(
                    'Login Now',
                    style: TextStyle(
                        color: Color.fromARGB(255, 47, 5, 65),
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
