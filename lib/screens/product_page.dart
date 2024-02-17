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

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.vendor,
    required this.isLiked,
  });
}

class ProductPage extends StatelessWidget {
  ProductPage({super.key});

  final List<Product> products = [
    Product(
        id: "p1",
        name: 'Temu bag',
        description: 'Great temu bag from temu',
        price: 29.99,
        images: ['lib/images/bag.png'],
        vendor: 'Temu',
        isLiked: false),
    Product(
        id: "p2",
        name: 'New Bike',
        description: 'Bike for sale, ',
        price: 120,
        images: ['lib/images/bike.png'],
        vendor: 'Adrian',
        isLiked: false),
    Product(
        id: "p3",
        name: 'Used Camera',
        description:
            'Selling cannon model x, no battery, willing to give SD card',
        price: 95,
        images: ['lib/images/camera.png'],
        vendor: 'Joe',
        isLiked: false),
    Product(
        id: "p4",
        name: 'Thrifted Shirt',
        description: 'Dope design, size M, willing to negotiate price',
        price: 25,
        images: ['lib/images/shirt.png'],
        vendor: 'Jill',
        isLiked: false),
    Product(
      id: "p5",
        name: 'Used e Scooter',
        description: 'Used e scooter, still in good conditon, up to 15mph',
        price: 70,
        images: ['lib/images/scooter.png'],
        vendor: 'test@gmail.com',
        isLiked: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SquareTileProduct(
              product: products[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(products[index]),
                  ),
                );
              },
            ),
          ]);

          /*

          
        
          return ListTile(
            title: Text(products[index].name),
            subtitle: Text('\$${products[index].price.toString()}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(products[index]),
                ),
              );
            },
          );
          */
        },
      ),
    );
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(product.images.first),
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
    );
  }
}
