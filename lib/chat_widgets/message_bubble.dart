import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
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
            color: isMe ? Color(0xff703efe) : Colors.grey,
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
                      ? Text(message.content,
                          style: const TextStyle(color: Colors.white))
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
  } catch (error) {
    if (error is StripeException) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error occured: ${error.error.localizedMessage}')));
    }
  }
}
