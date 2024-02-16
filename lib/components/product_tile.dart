import 'package:flutter/material.dart';
import 'package:practice_project/screens/product_page.dart';

class SquareTileProduct extends StatelessWidget {
  final Product product;
  final Function()? onTap;
  const SquareTileProduct(
      {super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 200,
          width: 200,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey[700],
            image: DecorationImage(
              image: AssetImage(product.images.first),
              fit: BoxFit.fill,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              Image.asset(
                product.images.first,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              // Text overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${naturalPrices(product.price)}', // Assuming 'price' is a property of the Product class
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          /*
        //child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              
            Text(
            product.name, 
            style: const TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.bold),

          ), 
          Text(
            '\$${product.price}',
            style: const TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.bold),
          ),

          ],)
          */
        )
        // ),

        );
  }
}

String naturalPrices(double price) {
  String p = price.toString();

  if (p.length > 3) {
    if (p.substring(p.length - 2) == ".0") {
      return p.substring(0, p.length - 2);
    } else if (p.substring(p.length - 2) == ".00") {
      return p.substring(0, p.length - 3);
    } else {
      return p;
    }
  }

  return p;
}
