import 'package:chatapp_final/pages/personal_chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({super.key});

  @override
  State<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot>? _results;
  bool _isLoading = false;
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  void _searchUsers(String query) async {
    if (query.isEmpty) return;

    setState(() => _isLoading = true);

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: query)
        .get();

    setState(() {
      _results = snapshot.docs;
      _isLoading = false;
    });
  }

  void _startChat(String currentUserId, String friendUid, String friendName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalChatPage(
          currentUserId: currentUserId,
          friendUid: friendUid,
          friendName: friendName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Users"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Enter user email",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchUsers(_searchController.text.trim()),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : _results == null
                ? const Text("Search for users to start chatting.")
                : Expanded(
              child: ListView.builder(
                itemCount: _results!.length,
                itemBuilder: (context, index) {
                  final userDoc = _results![index];
                  final user = userDoc.data() as Map<String, dynamic>;
                  final userId = userDoc.id;

                  if (userId == _currentUserId) return const SizedBox();

                  return ListTile(
                    title: Text(user['fullName'] ?? 'No Name'),
                    subtitle: Text(user['email'] ?? ''),
                    onTap: () => _startChat(
                      _currentUserId,
                      userId,
                      user['fullName'] ?? 'No Name',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
