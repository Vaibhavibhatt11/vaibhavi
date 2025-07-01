import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PersonalChatInfoPage extends StatelessWidget {
  final String userId;

  const PersonalChatInfoPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Info')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User data not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null) {
            return const Center(child: Text("No user data available"));
          }

          final String name = data['name'] ?? 'No Name';
          final String phone = data['phone'] ?? 'Not Set';
          final String profileImage = data['profileImage'] ?? '';
          final String status = data['status'] ?? 'offline';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImage.isNotEmpty
                      ? NetworkImage(profileImage)
                      : const AssetImage('assets/profile.png') as ImageProvider,
                ),
                const SizedBox(height: 20),
                Text(
                  name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 40),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(phone),
                  subtitle: const Text('Mobile'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.circle,
                    color: status == "online" ? Colors.green : Colors.grey,
                    size: 14,
                  ),
                  title: Text("Status: $status"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
