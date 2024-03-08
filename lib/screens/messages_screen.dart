import 'package:flutter/material.dart';
import 'package:practice_project/chat_widgets/user_item.dart';
import 'package:provider/provider.dart';

import '../../model/user.dart';
//import '../../provider/firebase_provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final userData = [
    const UserModel(
      uid: '1',
      name: 'Hazy',
      email: 'test@test.test',
      image: 'https://i.pravatar.cc/150?img=0',
    ),
    const UserModel(
        uid: '2',
        name: 'Ahmed',
        email: 'test@test.test',
        image: 'https://i.pravatar.cc/150?img=2'),
    const UserModel(
        uid: '3',
        name: 'Prateek',
        email: 'test@test.test',
        image: 'https://i.pravatar.cc/150?img=3'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
        ),
        body: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: userData.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) => UserItem(user: userData[index])),
      );
}