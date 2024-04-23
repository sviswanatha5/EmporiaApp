import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:practice_project/components/background.dart';
import 'package:practice_project/components/my_button.dart';
import 'package:practice_project/components/product_tile.dart';
import 'package:practice_project/screens/chat_screen.dart';
import 'package:practice_project/screens/product_page.dart';
import 'package:http/http.dart' as http;

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  ProductDetailScreen(this.product, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(product.name),
        ),
        body: Container(
          decoration: gradientDecoration(),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        18), // Adjust the border radius accordingly
                    child: CachedNetworkImage(
                      imageUrl: product.images.first,
                      fit: BoxFit.cover,
                      height: 200,
                      width: 200,
                    ),
                  ),
                ),
                // Display more pictures here using product.images
                // Use Image.network or Image.asset depending on where your images are located
                Text(
                  'Price: \$${naturalPrices(product.price)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
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

                const SizedBox(height: 10),

                Text(
                  getDateDifference(product),
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 50),

                MyButton(
                    onTap: () => {
                          analytics.logEvent(name: "vendor_contact"),
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                buyer: FirebaseAuth.instance.currentUser!.email ?? "",
                                vendor: product.vendor,
                                productId: product.id,
                              ),
                            ),
                          )
                        },
                    text: "Connect"),

                const SizedBox(height: 50),

                MyButton(
                    onTap: () => {
                          print('Pay button pressed'),
                          initPayment(FirebaseAuth.instance.currentUser!.email,
                              product, context)
                        },
                    text: "Pay"),

                const SizedBox(height: 200),
              ],
            ),
          ),
        ));
  }
}

String getDateDifference(Product product) {
  DateTime now = DateTime.now();

  DateTime productPosted = DateTime.parse(product.timeAdded.substring(0, 16));

  Duration difference = now.difference(productPosted);

  int daysDifference = difference.inDays;
  int hoursDifference = difference.inHours - 24 * daysDifference;
  int minutesDifference =
      difference.inMinutes - 60 * hoursDifference - 1440 * daysDifference;

  String days = (daysDifference == 1) ? "day" : "days";
  String hours = (hoursDifference == 1) ? "hour" : "hours";
  String minutes = (minutesDifference == 1) ? "minute" : "minutes";

  return "Posted $daysDifference $days, $hoursDifference $hours, $minutesDifference $minutes ago";
}

Future<void> initPayment(
    String? email, Product product, BuildContext context) async {
  try {
    print("Function entered");
    final response = await http.post(
        Uri.parse(
            "https://us-central1-cs4261assignment1.cloudfunctions.net/stripePaymentIntentRequest"),
        body: {
          'email': email,
          'amount': (product.price.toDouble() * 100).toString(),
        });

    final jsonResponse = jsonDecode(response.body);
    print(jsonResponse.toString());

    await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
      paymentIntentClientSecret: jsonResponse['paymentIntent'],
      merchantDisplayName: 'Emporia',
      customerId: jsonResponse['customer'],
      customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
    ));
    print("Made payment sheet");

    await Stripe.instance.presentPaymentSheet();
    print("done");

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Payment is successful')));
  } catch (error) {
    if (error is StripeException) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error occured: ${error.error.localizedMessage}')));
    }
  }
}

