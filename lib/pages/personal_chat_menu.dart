import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatapp_final/pages/auth/personal_chat_page.dart';

class PersonalChatMenu extends StatelessWidget {
  final String currentUserId;

  const PersonalChatMenu({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Chats')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs.where((doc) => doc.id != currentUserId);

          return ListView(
            children: users.map((userDoc) {
              String name = userDoc['fullName'] ?? 'No Name';
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(name),
                subtitle: Text(userDoc['email'] ?? ''),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PersonalChatPage(
                        currentUserId: currentUserId,
                        friendUid: userDoc.id,
                        friendName: name,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
