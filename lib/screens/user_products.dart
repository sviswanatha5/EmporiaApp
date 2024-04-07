import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:practice_project/components/background.dart";
import "package:practice_project/components/product_tile.dart";
import "package:practice_project/screens/for_you_page.dart";
import "package:practice_project/screens/product_page.dart";

class userProducts extends StatefulWidget {
  @override
  State<userProducts> createState() => _userProductsState();
}

final CollectionReference products =
    FirebaseFirestore.instance.collection('products');

class _userProductsState extends State<userProducts> {
  late Stream<List<Product>> _productsStream;

  @override
  void initState() {
    super.initState();
    _productsStream = loadUserProductsRealTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: gradientDecoration(),
        child: StreamBuilder<List<Product>>(
          stream: _productsStream,
          builder:
              (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Some error occurred'));
            }

            final List<Product>? userItems = snapshot.data;

            if (userItems == null || userItems.isEmpty) {
              return const Center(
                child: Text(
                  'No Listings',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
              );
            }

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
                    const SizedBox(height: 10),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Stream<List<Product>> loadUserProductsRealTime() {
    return FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .asyncMap((snapshot) async {
      final allProducts = await getProducts();
      final userProducts = await userProductsList(allProducts);
      return userProducts;
    });
  }

  Future<List<String>> getUserListings() async {
    try {
      // Retrieve the document snapshot from Firestore
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      // Check if the document exists
      if (!snapshot.exists) {
        throw Exception('User not found');
      }

      // Extract user listings from the document data
      List<String>? userListings = snapshot.data()?['userListings'] != null
          ? List<String>.from(snapshot.data()?['userListings'])
          : [];

      return userListings;
    } catch (e) {
      // Handle errors
      print('Error retrieving user listings: $e');
      rethrow; // Rethrow the exception to be caught by the caller
    }
  }

  Future<List<Product>> userProductsList(List<Product> allProducts) async {
    List<Product> userProducts = [];
    List<String> userProductIDs = await getUserListings();
    final String? email = FirebaseAuth.instance.currentUser!.email;

    for (int i = 0; i < allProducts.length; i++) {
      if (userProductIDs.contains(allProducts[i].id)) {
        userProducts.add(allProducts[i]);
      }

      if (allProducts[i].vendor == email &&
          !userProducts.contains(allProducts[i])) {
        userProducts.add(allProducts[i]);
      }
    }

    return userProducts;
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

  Future<void> addUserListing(DocumentReference userRef,
      Map<String, String> productIDMappings, Product product) async {
    List<String> userListings = await getUserListings();

    userListings.add(productIDMappings[product.id]!);
    updateUserListings(userRef, userListings);
  }

  Future<void> removeUserListing(DocumentReference userRef,
      Map<String, String> productIDMappings, Product product) async {
    List<String> userListings = await getUserListings();

    userListings.remove(productIDMappings[product.id]!);
    updateUserListings(userRef, userListings);
  }

  void updateUserListings(
      DocumentReference userRef, List<String> userListings) async {
    try {
      await userRef.update({'userListings': userListings});
      print('User favorites updated successfully');
    } catch (e) {
      print('Error updating user favorites: $e');
      // Handle error appropriately, such as showing a snackbar or dialog to the user
    }
  }
}
