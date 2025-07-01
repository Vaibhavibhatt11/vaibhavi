import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chatapp_final/helper/image_picker_helper.dart';

class GroupChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required String userName,
  });

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void sendMessage() async {
    if (_msgController.text.trim().isNotEmpty) {
      await _firestore
          .collection("groups")
          .doc(widget.groupId)
          .collection("messages")
          .add({
        "text": _msgController.text.trim(),
        "sender": _auth.currentUser!.displayName ?? "User",
        "uid": _auth.currentUser!.uid,
        "time": Timestamp.now(),
        "type": "text",
        "status": "sent"
      });
      _msgController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void pickImageAndSend(ImageSource source) async {
    String? base64Image;
    if (source == ImageSource.camera) {
      base64Image = await ImagePickerHelper.pickImageFromCamera();
    } else {
      base64Image = await ImagePickerHelper.pickImageFromGallery();
    }

    if (base64Image != null) {
      await _firestore
          .collection("groups")
          .doc(widget.groupId)
          .collection("messages")
          .add({
        "text": base64Image,
        "sender": _auth.currentUser!.displayName ?? "User",
        "uid": _auth.currentUser!.uid,
        "time": Timestamp.now(),
        "type": "image",
        "status": "sent"
      });
      _scrollToBottom();
    }
  }

  Widget buildMessage(DocumentSnapshot doc) {
    final isMe = doc['uid'] == _auth.currentUser!.uid;
    final msg = doc['text'];
    final type = doc['type'];
    final sender = doc['sender'];
    final time = doc['time'] as Timestamp;
    final status = doc['status'] ?? 'sent';

    Widget messageContent;
    if (type == "image") {
      try {
        final decoded = ImagePickerHelper.decodeBase64Image(msg);
        messageContent = Image.memory(
          decoded,
          width: 200,
          errorBuilder: (context, error, stackTrace) {
            return const Text("Image couldn't load", style: TextStyle(color: Colors.red));
          },
        );
      } catch (e) {
        messageContent = const Text("Invalid image", style: TextStyle(color: Colors.red));
      }
    } else {
      messageContent = Text(msg, style: const TextStyle(fontSize: 16));
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.deepPurple[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(sender,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 5),
            messageContent,
            const SizedBox(height: 5),
            Text(
              time.toDate().toLocal().toString().substring(0, 16),
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
            if (isMe)
              Text(status,
                  style: const TextStyle(fontSize: 10, color: Colors.green))
          ],
        ),
      ),
    );
  }

  void showAllUsersBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('users').get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text("No users found.")),
              );
            }

            final currentUid = _auth.currentUser!.uid;
            final users = snapshot.data!.docs
                .where((doc) => doc.id != currentUid)
                .toList();

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final name = user['fullName'] ?? 'User';
                final email = user['email'] ?? '';

                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(name),
                  subtitle: Text(email),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$name selected')),
                    );
                    // TODO: Add this user to the group if needed
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'View Users',
            onPressed: showAllUsersBottomSheet,
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () => pickImageAndSend(ImageSource.camera),
          ),
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: () => pickImageAndSend(ImageSource.gallery),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection("groups")
                  .doc(widget.groupId)
                  .collection("messages")
                  .orderBy("time", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: \${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No messages yet"));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      buildMessage(messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration:
                    const InputDecoration(hintText: "Type message..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
