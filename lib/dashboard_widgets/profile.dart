import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

class ProfileWidget extends StatelessWidget{

final String _email = FirebaseAuth.instance.currentUser!.email.toString();

void signUserOut() {
    FirebaseAuth.instance.signOut();
}

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Profile',
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text('Email: $_email'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: OutlinedButton(
            onPressed: () {
              // TODO
            },
            child: const Text('Edit Profile'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: OutlinedButton(
            onPressed: () {
              signUserOut();
            },
            child: const Text('Logout'),
          ),
        ),
      ],
    );
  }

}