import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import 'package:practice_project/components/product_tile.dart';
import "package:practice_project/components/product_button.dart";

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final String vendor;
  bool isLiked;
  List<bool> productGenre = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  Product(
      {required this.id,
      required this.name,
      required this.description,
      required this.price,
      required this.images,
      required this.vendor,
      required this.isLiked,
      required this.productGenre});
}

final CollectionReference products =
    FirebaseFirestore.instance.collection('products');

class ProductPage extends StatefulWidget {
  ProductPage({Key? key}) : super(key: key) {
    stream = products.snapshots();
  }

  late Stream<QuerySnapshot> stream;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  //retrieve all products from Firestore
  Future<List<Product>> getProducts() async {
    QuerySnapshot querySnapshot = await products.get();

    List<Product> productList = [];

    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      productList.add(Product(
        description: data['description'],
        id: data['id'],
        price: data['price'],
        name: data['name'],
        images: data['images'],
        isLiked: data['isLiked'],
        vendor: data['vendor'],
        productGenre: List<bool>.from(data['productGenre']),
      ));
    }

    return productList;
  }

  List<Product> loadedProductList = [];
  List<Product> filteredProductList = [];

  Future<void> loadProducts() async {
    List<Product> loadedProducts = await getProducts();
    loadedProductList = loadedProducts;
    filteredProductList = loadedProducts;
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<QuerySnapshot>(
            stream: widget.stream,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Some error occured'));
              }

              if (snapshot.hasData) {
                QuerySnapshot querySnapshot = snapshot.data;
                List<QueryDocumentSnapshot> documents = querySnapshot.docs;

                List<Product> items = documents.map((data) {
                  return Product(
                      id: data['id'],
                      name: data['name'],
                      description: data['description'],
                      price: data['price']
                          .toDouble(), // Assuming 'price' is stored as a double
                      images: List<String>.from(data['images']),
                      isLiked: data['isLiked'],
                      vendor: data['vendor'],
                      productGenre: List<bool>.from(data['productGenre']));
                }).toList();

                void filterProducts(String query) {
                  setState(() {
                    if (query.isNotEmpty) {
                      // Otherwise, filter products based on the search query
                      filteredProductList = items.where((product) {
                        // Check if the product name contains the search query
                        return product.name
                            .toLowerCase()
                            .contains(query.toLowerCase());
                      }).toList();

                      print(query);
                    } else {
                      filteredProductList = items;
                    }
                  });
                }

                List<Product> filteredItems = filteredProductList;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (String value) {
                          filterProducts(value);
                        },
                        decoration: const InputDecoration(
                          labelText: 'Search',
                          suffixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SquareTileProduct(
                                  product: filteredItems[index],
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailScreen(
                                                filteredItems[index]),
                                      ),
                                    );
                                  },
                                ),
                              ]);
                        },
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }
}

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen(this.product);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(product.images.first),
            // Display more pictures here using product.images
            // Use Image.network or Image.asset depending on where your images are located
            Text(
              'Price: \$${naturalPrices(product.price)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Description: ${product.description}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 10),
            Text(
              'Contact: ${product.vendor}',
              style: const TextStyle(fontSize: 16),
            ),
            // Add more details as needed

            const SizedBox(height: 100),

            MyButton(onTap: () => {}, text: "Connect"),
          ],
        ),
      ),
    );
  }
}
