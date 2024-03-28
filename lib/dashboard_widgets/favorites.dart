import "package:flutter/material.dart";
import "package:practice_project/components/product_tile.dart";
import "package:practice_project/screens/product_page.dart";
import "package:practice_project/components/background.dart";

List<Product> favoriteProducts = [];

class FavoriteProducts extends StatefulWidget {
  const FavoriteProducts({super.key});

  @override
  State<FavoriteProducts> createState() => _FavoriteProductsState();
}



class _FavoriteProductsState extends State<FavoriteProducts> {




  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: gradientDecoration(),
        child: ListView.builder(
          itemCount: favoriteProducts.length,
          itemBuilder: (context, index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SquareTileProduct(
                  product: favoriteProducts[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailScreen(favoriteProducts[index]),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }




 
}

void addFavorite(Product product) {

  if(!favoriteProducts.contains(product)){

 
      favoriteProducts.add(product);
    
     
  }
    
  }

  void removeFavorite(Product product) {

    
      favoriteProducts.remove(product);
   
    
  }

 