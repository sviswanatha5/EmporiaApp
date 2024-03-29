import "dart:io";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import "package:practice_project/screens/product_page.dart";
import 'package:firebase_storage/firebase_storage.dart';
import 'package:practice_project/components/background.dart';

class AddProduct extends StatefulWidget {
  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  File? image;
  static int counter = 0;

  String imageUrl = '';

  bool addProductButtonDisabled = false;

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    XFile? pickedFile;

    try {
      pickedFile = await picker.pickImage(
        source: ImageSource
            .gallery, // Use ImageSource.camera for capturing from camera
      );
    } catch (e) {
      print("Error picking image: $e");
    }

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile!.path);
      });
    }
  }

  final CollectionReference products =
      FirebaseFirestore.instance.collection('products');

  //Add products to database

  Future<void> addProduct(Product product) async {
    await products.add({
      'name': product.name,
      'id': product.id,
      'description': product.description,
      'price': product.price,
      'images': product.images,
      'vendor': product.vendor,
      'isLiked': product.isLiked,
      'timeAdded': product.timeAdded,
      'productGenre' : product.productGenre
    });
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController vendorController = TextEditingController();

  final List<String> genres = [
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

  List<bool> selectedGenres = [
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

  //stdout.write()

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sell an Item'),
      ),

      body: Container(
        decoration: gradientDecoration(),
        child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 100,
                height: 300,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: Colors.grey[400],
                    image: image != null
                        ? DecorationImage(
                            image: FileImage(File(image!.path)),
                            fit: BoxFit.cover)
                        : null),
              ),
              IconButton(
                  onPressed: () => pickImages(),
                  icon: const Icon(Icons.camera_alt)),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Item Name'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Price'),
              ),
              SizedBox(height: 32),
              Text("Product Type"),
              SizedBox(height: 16),
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
                        selectedGenres[index] = !selectedGenres[index];
                      });
                      //print('Button $index pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedGenres[index]
                          ? Colors.purple[
                              100] // Change to your desired color when clicked
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            10.0), // Adjust the border radius
                      ),
                      side: const BorderSide(
                          color:  Color.fromARGB(255, 74, 20, 140)),
                      padding: const EdgeInsets.all(
                          8.0), // Adjust the padding around the text
                    ),
                    child: Text(genres[index]),
                  );
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: addProductButtonDisabled
                    ? null
                    : () {
                        setState(() {
                          addProductButtonDisabled = true;
                        });

                        buttonLogic();

                        setState(() {
                          addProductButtonDisabled = false;
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      addProductButtonDisabled ? Colors.grey : null,
                ),
                child: Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  void buttonLogic() async {
    await Future.delayed(const Duration(seconds: 2));

    Reference reference = FirebaseStorage.instance.ref();
    Reference refImages = reference.child('images');

    String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();

    Reference uploadImage = refImages.child(imageFileName);

    try {
      await uploadImage.putFile(File(image!.path));
      imageUrl = await uploadImage.getDownloadURL();
    } catch (error) {}

    String dateAdded = DateTime.now().toString();

    //debugPrint(priceController.toString());
    Product newProduct = Product(
        name: nameController.text.trim(),
        price: double.parse(priceController.text.trim()),
        description: descriptionController.text.trim(),
        vendor: FirebaseAuth.instance.currentUser!.email.toString(),
        isLiked: false,
        images: [imageUrl],
        id: "product${counter++}",
        timeAdded: dateAdded,
        productGenre: selectedGenres);

    addProduct(newProduct);

    nameController.clear();
    descriptionController.clear();
    priceController.clear();

    selectedGenres = [
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

    setState(() {
      image = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product Added!'),
        duration: Duration(milliseconds: 900),
      ),
    );
  }
}
