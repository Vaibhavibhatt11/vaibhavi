import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'personal_chat_page.dart';

class PersonalChatMenuPage extends StatelessWidget {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  PersonalChatMenuPage({Key? key}) : super(key: key);

  void _startNewChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => NewChatSelector(currentUserId: currentUserId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Personal Chats")),
      body: Center(
        child: const Text("Click '+' to start a new chat."),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startNewChat(context),
        child: const Icon(Icons.chat),
        tooltip: "Start New Chat",
      ),
    );
  }
}

class NewChatSelector extends StatelessWidget {
  final String currentUserId;

  const NewChatSelector({Key? key, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Scaffold(
          appBar: AppBar(title: const Text("Select User")),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

              final users = snapshot.data!.docs;

              return ListView(
                children: users.map((userDoc) {
                  final userData = userDoc.data() as Map<String, dynamic>;

                  if (userData['uid'] == currentUserId) return const SizedBox.shrink();

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: (userData['profileImage'] != null && userData['profileImage'].isNotEmpty)
                          ? NetworkImage(userData['profileImage'])
                          : null,
                      child: (userData['profileImage'] == null || userData['profileImage'].isEmpty)
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(userData['fullName'] ?? 'No Name'),
                    subtitle: Text(userData['email'] ?? ''),
                    onTap: () {
                      Navigator.pop(context); // Close bottom sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PersonalChatPage(
                            currentUserId: currentUserId,
                            friendUid: userData['uid'],
                            friendName: userData['fullName'] ?? 'No Name',
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}
