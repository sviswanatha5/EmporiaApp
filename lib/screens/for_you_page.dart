import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_analytics/firebase_analytics.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:practice_project/components/product_tile.dart";
import "package:practice_project/components/user_tile.dart";
import "package:practice_project/screens/product_page.dart";
import 'package:practice_project/components/background.dart';
import "package:practice_project/screens/product_page_description.dart";

final CollectionReference products =
    FirebaseFirestore.instance.collection('products');
final String _email = FirebaseAuth.instance.currentUser!.email.toString();
List<UserDuration> userDurations = [];
final Map<String, String> productIDMappings = {};
int userCount = 0;

class ForYouPage extends StatefulWidget {
  ForYouPage({Key? key}) : super(key: key);

  @override
  State<ForYouPage> createState() => _ForYouPageState();
}

class UserDuration {
  late String user;
  late int durationSeconds;

  UserDuration(this.user, this.durationSeconds);
  String toString() {
    return '(User: $user, Duration: $durationSeconds seconds)';
  }
}

class _ForYouPageState extends State<ForYouPage> with WidgetsBindingObserver {
  late DateTime _pageOpenTime;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    _pageOpenTime = DateTime.now();
    WidgetsBinding.instance?.addObserver(this);
    updateUserListingsLength();
    userCount = 0;
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    _trackPageDuration();
  }

  void _trackPageDuration() {
    DateTime pageCloseTime = DateTime.now();
    Duration duration = pageCloseTime.difference(_pageOpenTime);
    print("$_email spent ${duration.inSeconds} seconds on ForYouPage.");
    userDurations.add(UserDuration(_email, duration.inSeconds));
    print(userDurations);
    // You can send this duration to analytics or store it as needed
  }

  Map<String, int> userListingCount = {};

  Future<void> updateUserListingsLength() async {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final usersSnapshot = await usersCollection.get();

    // Iterate over each user document
    for (final userDoc in usersSnapshot.docs) {
      final userUid = userDoc.id;
      final userListings =
          userDoc['userListings'] ?? []; // Assume it's a list of strings
      final userListingsLength = userListings.length;

      // Fetch user's first name and last name
      final userNameSnapshot = await usersCollection.doc(userUid).get();
      final firstName = userNameSnapshot['firstname'];
      final lastName = userNameSnapshot['lastname'];

      // Combine first name and last name to form user name
      final userName = '$firstName $lastName';

      setState(() {
        userListingCount[userUid] = userListingsLength;
      });
    }
  }

  Future<List<Product>> loadUserProducts() async {
    List<Product> userItems = await userPreferenceProducts(await getProducts());
    return userItems;
  }

  Future<List<Product>> getProducts() async {
    QuerySnapshot querySnapshot = await products.get();

    List<Product> productList = [];

    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      productList.add(Product(
        id: data['id'],
        name: data['name'],
        description: data['description'],
        price: data['price'].toDouble(),
        images: List<String>.from(data['images']),
        isLiked: data['isLiked'],
        vendor: data['vendor'],
        timeAdded: data['timeAdded'],
        productGenre: List<bool>.from(data['productGenre']),
      ));

      productIDMappings[data['id']] = documentSnapshot.id;
    }

    return productList;
  }

  @override
  Widget build(BuildContext context) {
    final sortedUserUids = userListingCount.keys.toList()
      ..sort((a, b) => userListingCount[b]!.compareTo(userListingCount[a]!));
    userCount = 0;

    return Scaffold(
      body: Container(
        decoration: gradientDecoration(), // Applying the gradient decoration
        child: FutureBuilder<List<Product>>(
          future: loadUserProducts(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Some error occurred'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No products found',
                  style: TextStyle(
                    fontSize: 22, // Adjust the font size as needed
                    color: Colors.white, // Set the color to white
                  ),
                ),
              );
            }

            List<Product> userItems = snapshot.data!;

            for (int i = 0; i < userItems.length; i++) {
              print(userItems[i].name);
            }

            return Center(
              child: Container(
                padding: EdgeInsets.all(10), // Add padding around all borders
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing: 15, // Spacing between columns
                    mainAxisSpacing: 15, // Spacing between rows
                    // Aspect ratio of each item (width / height)
                  ),
                  itemCount: userItems.length,
                  itemBuilder: (context, index) {
                    if ((index + 1) % 3 == 0 &&
                        userCount < sortedUserUids.length) {
                      return RoundedRectangularFeaturedUser(
                        userUid: sortedUserUids[userCount++],
                      );
                    } else {
                      print(userCount);
                      return SquareTileProduct(
                        product: userItems[index],
                        onTap: () {
                          analytics.logViewItem(
                              currency: 'usd',
                              value: userItems[index].price,
                              parameters: <String, dynamic>{
                                'name': userItems[index].name,
                                'id': userItems[index].id,
                                'vendor': userItems[index].vendor,
                                'productGenre':
                                    userItems[index].productGenre.toString()
                              });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(userItems[index]),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<List<bool>> getPreferences() async {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .get();

      if (userSnapshot.exists) {
        List<bool> preferences =
            List<bool>.from(userSnapshot['preferences'] ?? []);
        return preferences;
      } else {
        print('User document does not exist');
        return [];
      }
    } catch (e) {
      print('Error getting preferences: $e');
      return [];
    }
  }

  Future<List<Product>> userPreferenceProducts(
      List<Product> allProducts) async {
    List<Product> userPreferredProducts = [];

    List<bool> userPreferences = await getPreferences();

    for (int i = 0; i < allProducts.length; i++) {
      bool isMatch = false;
      List<bool> productGenre = allProducts[i].productGenre;

      for (int j = 0; j < 9; j++) {
        if (userPreferences[j] == true &&
            productGenre[j] == userPreferences[j]) {
          isMatch = true;
          break;
        }
      }

      if (isMatch) {
        userPreferredProducts.add(allProducts[i]);
      }
    }

    return userPreferredProducts;
  }
}
