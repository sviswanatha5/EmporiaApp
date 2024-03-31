import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:practice_project/components/product_tile.dart";
import "package:practice_project/screens/for_you_page.dart";
import "package:practice_project/screens/product_page.dart";
import "package:practice_project/components/background.dart";

class FavoriteProducts extends StatefulWidget {
  const FavoriteProducts({super.key});

  @override
  State<FavoriteProducts> createState() => _FavoriteProductsState();
}

class _FavoriteProductsState extends State<FavoriteProducts> {
  late List<String> favoriteProductsID;
  late CollectionReference products;

  @override
  void initState() {
    super.initState();
    initializeUserData();
  }

  Future<void> initializeUserData() async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(currentUserUid);

    final userSnapshot = await userRef.get();

    if (userSnapshot.exists) {
      favoriteProductsID =
          List<String>.from(userSnapshot['favoriteProducts'] ?? []);
      products = FirebaseFirestore.instance.collection('products');
    } else {
      print('User document does not exist');
      favoriteProductsID = [];
    }
  }

  Future<List<Product>> loadFavoriteUserProducts() async {
    await initializeUserData();
    final userItems = await getFavoriteProducts();
    return userItems;
  }

  Future<List<Product>> getFavoriteProducts() async {
    QuerySnapshot querySnapshot = await products.get();

    List<Product> productList = [];

    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      if (favoriteProductsID.contains(documentSnapshot.id)) {
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
    }

    return productList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: gradientDecoration(), // Applying the gradient decoration
        child: FutureBuilder<List<Product>>(
          future: loadFavoriteUserProducts(),
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
                  'No Favorites Selected',
                  style: TextStyle(
                    fontSize: 22, // Adjust the font size as needed
                    color: Colors.white, // Set the color to white
                  ),
                ),
              );
            }

            List<Product> userItems = snapshot.data!;

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
}

void addFavorite(DocumentReference userRef, List<String> favoriteProductsID,
    Map<String, String> productIDMappings, Product product) {
  if (!favoriteProductsID.contains(productIDMappings[product.id])) {
    favoriteProductsID.add(productIDMappings[product.id]!);
    updateUserFavorites(userRef, favoriteProductsID);
  }
}

void removeFavorite(DocumentReference userRef, List<String> favoriteProductsID,
    Map<String, String> productIDMappings, Product product) {
  favoriteProductsID.remove(productIDMappings[product.id]);
  updateUserFavorites(userRef, favoriteProductsID);
}

void updateUserFavorites(
    DocumentReference userRef, List<String> newFavorites) async {
  try {
    await userRef.update({'favoriteProducts': newFavorites});
    print('User favorites updated successfully');
  } catch (e) {
    print('Error updating user favorites: $e');
    // Handle error appropriately, such as showing a snackbar or dialog to the user
  }
}

 