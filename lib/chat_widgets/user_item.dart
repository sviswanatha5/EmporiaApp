import 'package:flutter/material.dart';
import 'package:practice_project/screens/chat_screen.dart';

import '../../model/user.dart';

class UserItem extends StatefulWidget {
  const UserItem({super.key, required this.vendor, required this.productId});
  final String vendor;
  final String productId;

  @override
  State<UserItem> createState() => _UserItemState();
}

class _UserItemState extends State<UserItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ChatScreen(
                  vendor: widget.vendor,
                  productId: widget.productId,
                ))),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                    'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 10),
              //   child: CircleAvatar(,
              //     radius: 5,
              //   ),
              // ),
            ],
          ),
          title: Text(
            widget.vendor,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
}
