import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("All Users")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs.where(
                (doc) => doc.id != currentUser!.uid,
          );

          return ListView(
            children: users.map((user) {
              final data = user.data() as Map<String, dynamic>;

              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(data['fullName'] ?? 'User'),
                subtitle: Text(data['email'] ?? ''),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/personal chat',
                    arguments: {
                      'receiverId': user.id,
                      'receiverName': data['fullName'] ?? 'User',
                      'currentUserId': currentUser!.uid,
                      'friendUid': user.id,
                      'friendName': data['fullName'] ?? 'User',
                    },
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
