import "dart:io";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import "package:practice_project/screens/product_page.dart";
import 'package:firebase_storage/firebase_storage.dart';

class AddProduct extends StatefulWidget {
  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  File? image;
  var counter = 0;

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
    });
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController vendorController = TextEditingController();

  //stdout.write()

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sell an Item'),
      ),
      body: SingleChildScrollView(
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

              /*
              GestureDetector(

                onTap: () => _pickImages(),
                child: Container(
                  padding: const EdgeInsets.all(100),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[200],
                  ),
                  child: image != null
                      ? Image.file(image!, height: 200, width: 200)
                      : const Icon(
                          Icons.camera_alt,
                          size: 40.0,
                        ),
                ),
              ),

               
            IconButton(
              onPressed: () => _pickImages(), 
              icon: Icon(Icons.)),

              */
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
              SizedBox(height: 16),
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
                  backgroundColor: addProductButtonDisabled ? Colors.grey : null,
                ),
                child: Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
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

    //debugPrint(priceController.toString());
    Product newProduct = Product(
        name: nameController.text.trim(),
        price: double.parse(priceController.text.trim()),
        description: descriptionController.text.trim(),
        vendor: FirebaseAuth.instance.currentUser!.email.toString(),
        isLiked: false,
        images: [imageUrl],
        id: "product ${counter++}");

    addProduct(newProduct);

    nameController.clear();
    descriptionController.clear();
    priceController.clear();

    setState(() {
      image = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product Added!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
