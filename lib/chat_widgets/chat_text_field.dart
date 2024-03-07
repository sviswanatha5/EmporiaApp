import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'custom_text_form_field.dart';

class ChatTextField extends StatefulWidget {
  const ChatTextField({super.key});

  @override
  State<ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<ChatTextField> {
  final controller = TextEditingController();

  Uint8List? file;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
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
          const SizedBox(width: 5),
          CircleAvatar(
            backgroundColor: Color(0xff703efe),
            radius: 20,
            child: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              onPressed: _sendImage,
            ),
          ),
        ],
      );

  Future<void> _sendText(BuildContext context) async {
    if (controller.text.isNotEmpty) {
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

  Future<void> _sendImage() async {
    // final pickedImage = await MediaService.pickImage();
    // setState(() => file = pickedImage);
    // if (file != null) {
    //   await FirebaseFirestoreService.addImageMessage(
    //     receiverId: widget.receiverId,
    //     file: file!,
    //   );
    //   await notificationsService.sendNotification(
    //     body: 'image........',
    //     senderId: FirebaseAuth.instance.currentUser!.uid,
    //   );
    // }
  }
}
