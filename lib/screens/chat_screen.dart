import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_project/chat_widgets/custom_text_form_field.dart';
import 'package:practice_project/chat_widgets/message_bubble.dart';
import 'package:practice_project/model/message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.vendor, required this.productId});

  final String vendor;
  final String productId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String docRef = "none";
  @override
  void initState() {
    super.initState();
    getDocRef();
  }

  final controller = TextEditingController();

  Uint8List? file;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  getDocRef() async {
    await FirebaseFirestore.instance
        .collection("chat")
        .where('productId', isEqualTo: widget.productId)
        .where('vendor', isEqualTo: widget.vendor)
        .where('buyer', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .limit(1)
        .get()
        .then((value) => setState(() {
              docRef = value.docs[0].reference.path;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder(
              stream: docRef == "none"
                  ? null
                  : FirebaseFirestore.instance
                      .collection("$docRef/messages")
                      .orderBy("sentTime")
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.hasError) {
                  return const Center(child: Text('No messages yet!'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final Message message =
                        Message.fromJson(snapshot.data!.docs[index].data());
                    final bool isMe = message.senderId !=
                        FirebaseAuth.instance.currentUser!.email;
                    final isTextMessage =
                        message.messageType == MessageType.text;

                    return isTextMessage
                        ? MessageBubble(
                            isMe: isMe,
                            message: message,
                            isImage: false,
                          )
                        : MessageBubble(
                            isMe: isMe,
                            message: message,
                            isImage: true,
                          );
                  },
                );
              },
            )),
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: controller,
                    hintText: 'Add Message...',
                  ),
                ),
                const SizedBox(width: 5),
                CircleAvatar(
                  backgroundColor: Color(0xff703efe),
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _sendText(context),
                  ),
                ),
                // const SizedBox(width: 5),
                // CircleAvatar(
                //   backgroundColor: Color(0xff703efe),
                //   radius: 20,
                //   child: IconButton(
                //     icon: const Icon(Icons.camera_alt, color: Colors.white),
                //     onPressed: _sendImage,
                //   ),
                // ),
              ],
            )
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(
      elevation: 0,
      foregroundColor: Colors.black,
      backgroundColor: Colors.transparent,
      title: Row(
        children: [
          const CircleAvatar(
            backgroundImage: NetworkImage(
                'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
            radius: 20,
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Text(
                widget.vendor,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ));

  Future<void> _sendText(BuildContext context) async {
    if (controller.text.isNotEmpty) {
      if (docRef == "none") {
        FirebaseFirestore.instance.collection('chat').add({
          "productId": widget.productId,
          "vendor": widget.vendor,
          "buyer": FirebaseAuth.instance.currentUser!.email
        }).then((value) => setState(() {
              docRef = value.path;
            }));
      }
      FirebaseFirestore.instance.collection("$docRef/messages").add({
        "content": controller.text,
        "messageType": "text",
        "senderId": FirebaseAuth.instance.currentUser!.email,
        "sentTime": DateTime.now()
      });
      // await FirebaseFirestoreService.addTextMessage(
      //   receiverId: widget.receiverId,
      //   content: controller.text,
      // );
      // await notificationsService.sendNotification(
      //   body: controller.text,
      //   senderId: FirebaseAuth.instance.currentUser!.uid,
      // );
      controller.clear();
      FocusScope.of(context).unfocus();
    }
    FocusScope.of(context).unfocus();
  }
}
