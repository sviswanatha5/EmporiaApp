import "package:flutter/material.dart";
import 'package:practice_project/components/product_tile.dart';
import "package:practice_project/components/product_button.dart";

class Product {
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final String vendor;

  Product(
      {required this.name,
      required this.description,
      required this.price,
      required this.images,
      required this.vendor});
}

class ProductPage extends StatelessWidget {
  ProductPage({super.key});

  final List<Product> products = [
    Product(
        name: 'Temu bag',
        description: 'Great temu bag from temu',
        price: 29.99,
        images: ['lib/images/bag.png'],
        vendor: 'Temu'),
    Product(
        name: 'New Bike',
        description: 'Bike for sale, ',
        price: 120,
        images: ['lib/images/bike.png'],
        vendor: 'Adrian'),
    Product(
        name: 'Used Camera',
        description:
            'Selling cannon model x, no battery, willing to give SD card',
        price: 95,
        images: ['lib/images/camera.png'],
        vendor: 'Joe'),
    Product(
        name: 'Thrifted Shirt',
        description: 'Dope design, size M, willing to negotiate price',
        price: 25,
        images: ['lib/images/shirt.png'],
        vendor: 'Jill'),
    Product(
        name: 'Used e Scooter',
        description: 'Used e scooter, still in good conditon, up to 15mph',
        price: 70,
        images: ['lib/images/scooter.png'],
        vendor: 'test@gmail.com'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          const SizedBox(height: 30);

          /*
          return SquareTile(
            product: products[index],
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

          MyButton(onTap: () => {}, text: "Buy Now"),
        ],
      ),
    );
  }
}
