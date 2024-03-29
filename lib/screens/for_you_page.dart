import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:practice_project/components/product_tile.dart";
import "package:practice_project/screens/product_page.dart";
import 'package:practice_project/components/background.dart';

final CollectionReference products =
    FirebaseFirestore.instance.collection('products');

class ForYouPage extends StatefulWidget {
  ForYouPage({super.key}) {
    stream = products.snapshots();
  }

  late Stream<QuerySnapshot> stream;

  @override
  State<ForYouPage> createState() => _ForYouPageState();
}

class _ForYouPageState extends State<ForYouPage> {
  // retrieve all products from Firestore

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
    }

    return productList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: gradientDecoration(), // Applying the gradient decoration
        child: FutureBuilder<List<Product>>(
          future: loadUserProducts(),
          builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
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
            /* 
            return ListView.builder(
              itemCount: userItems.length,
              itemBuilder: (context, index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTileProduct(
                      product: userItems[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(userItems[index]),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
            */

            return Center(
              child: Container(
                padding: EdgeInsets.all(10), // Add padding around all borders
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing: 15, // Spacing between columns
                    mainAxisSpacing: 15, // Spacing between rows
                    // Aspect ratio of each item (width / height)
                  ),
                  itemCount: userItems.length,
                  itemBuilder: (context, index) {
                    return SquareTileProduct(
                      product: userItems[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(userItems[index]),
                          ),
                        );
                      },
                    );
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
        if (userPreferences[j] == true && productGenre[j] == userPreferences[j] ) {
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
