import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import '../../model/message.dart';
import 'package:http/http.dart' as http;

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.isMe,
    required this.isImage,
    required this.message,
    required this.isPayment,
    required this.isVendor,
    required this.buyer,
  });

  final bool isMe;
  final bool isImage;
  final bool isPayment;
  final bool isVendor;
  final Message message;
  final String buyer;

  @override
  Widget build(BuildContext context) => Align(
        alignment: isMe ? Alignment.topLeft : Alignment.topRight,
        child: Container(
          decoration: BoxDecoration(
            color: isMe ? Colors.grey : Colors.blue,
            borderRadius: isMe
                ? const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  ),
          ),
          margin: const EdgeInsets.only(top: 10, right: 10, left: 10),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              isImage
                  ? Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: NetworkImage(message.content),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : !isPayment
                      ? Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                          children: [
                            Text(
                              message.content,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16, // Adjust the font size as needed
                              ),
                            ),
                            Text(
                              formatTime(message.sentTime),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : !isVendor
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color:
                                    Colors.blue, // Change the color as needed
                              ),
                              padding: EdgeInsets.all(10),
                              child: GestureDetector(
                                onTap: () {
                                  initPayment(buyer, message.content, context);
                                },
                                child: Text(
                                  '\$${message.content}', // Replace 'Your Price' with the actual price
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              
                            )
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color:
                                    Colors.blue, // Change the color as needed
                              ),
                              padding: EdgeInsets.all(10),
                              child: Text(
                                '\$${message.content}', // Replace 'Your Price' with the actual price
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      );
}

void _sendConfirmationMessage(BuildContext context, String message) {
  String docRef = ModalRoute.of(context)!.settings.arguments
      as String; // Get the docRef from the route arguments

  FirebaseFirestore.instance.collection("$docRef/messages").add({
    "content": message,
    "messageType": "text",
    "senderId": FirebaseAuth.instance.currentUser!.email,
    "sentTime": DateTime.now()
  });
}

Future<void> initPayment(
    String? email, String price, BuildContext context) async {
  try {
    print("Function entered");
    final response = await http.post(
        Uri.parse(
            "https://us-central1-cs4261assignment1.cloudfunctions.net/stripePaymentIntentRequest"),
        body: {
          'email': email,
          'amount': (double.parse(price) * 100).toString(),
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

    String confirmationMessage = 'Payment of \$$price successful!';
    //_sendConfirmationMessage(context, confirmationMessage);
  } catch (error) {
    if (error is StripeException) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error occured: ${error.error.localizedMessage}')));
    }
  }
}

String formatTime(DateTime dateTime) {
  final formattedTime = DateFormat('MM/dd hh:mm a').format(dateTime);
  return formattedTime;
}
