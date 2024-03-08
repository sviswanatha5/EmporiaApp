import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

class ProfileWidget extends StatelessWidget {
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ButtonGridScreen()));
            },
            child: const Text('Edit Preferences'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: OutlinedButton(
            onPressed: () {
              launchFeedbackForm();
            },
            child: const Text('FeedBack!'),
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

launchFeedbackForm() async {
  Uri formsWebsite = Uri.parse( 'https://forms.gle/KAXmLJtCWutYXsXr5');
  if (await canLaunchUrl(formsWebsite)) {
    await launchUrl(formsWebsite);
  } else {
    throw 'Could not launch';
  }
}

class ButtonGridScreen extends StatefulWidget {
  @override
  _ButtonGridScreenState createState() => _ButtonGridScreenState();
}

class _ButtonGridScreenState extends State<ButtonGridScreen> {
  List<bool> userPreferences = [];

  @override
  void initState() {
    super.initState();
    fetchUserPreferences();
  }

  Future<void> fetchUserPreferences() async {
    List<bool> preferences = await getUserPreferences();
    setState(() {
      userPreferences = preferences;
    });
  }

  final List<String> preferences = [
    "Vintage",
    "Tops",
    "Bottoms",
    "Tech",
    "Jewlery",
    "Accessories",
    "Books",
    "Shoes",
    "Decor"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick Your Preferences'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 3x3 Grid of "Shirts" Buttons
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              shrinkWrap: true,
              itemCount: 9,
              itemBuilder: (BuildContext context, int index) {
                return ElevatedButton(
                  onPressed: () {
                    // Handle button press
                    setState(() {
                      userPreferences[index] = !userPreferences[index];
                    });
                    //print('Button $index pressed');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: userPreferences[index]
                        ? Colors.purple[
                            100] // Change to your desired color when clicked
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10.0), // Adjust the border radius
                    ),
                    side: BorderSide(
                        color: const Color.fromARGB(255, 74, 20, 140)),
                    padding: EdgeInsets.all(
                        8.0), // Adjust the padding around the text
                  ),
                  child: Text(preferences[index]),
                );
              },
            ),
            SizedBox(height: 16.0), // Spacer

            // Submit Button
            ElevatedButton(
              onPressed: () {
                try {
                  FirebaseAuth user = FirebaseAuth.instance;

                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.currentUser?.uid)
                      .set({
                    'uid': user.currentUser?.uid,
                    'email': user.currentUser!.email,
                    'preferences': userPreferences,
                  }, SetOptions(merge: true));

                  Navigator.pop(context);
                } on FirebaseAuthException catch (exception) {}
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<bool>> getUserPreferences() async {
    // Get the current user's UID
    String uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Get the user's preferences document from Firestore
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users') // Change to your Firestore collection name
              .doc(uid) // Use the UID to identify the specific user
              .get();

      // Check if the document exists
      if (snapshot.exists) {
        // Retrieve the "preferences" field from the document
        List<dynamic> preferences = snapshot.data()!['preferences'];

        // Return the preferences'

        List<bool> prefs = preferences.map((dynamic value) {
          if (value is bool) {
            return value;
          }
          return false;
        }).toList();

        return prefs;
      } else {
        // Document does not exist
        print('User preferences not found.');
        return [false, false, false, false, false, false, false, false, false];
      }
    } catch (e) {
      // Handle errors
      print('Error getting user preferences: $e');
      return [false, false, false, false, false, false, false, false, false];
    }
  }
}
