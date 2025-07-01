import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chatapp_final/helper/image_picker_helper.dart';

class PersonalChatPage extends StatefulWidget {
  final String currentUserId;
  final String friendUid;
  final String friendName;

  const PersonalChatPage({
    Key? key,
    required this.currentUserId,
    required this.friendUid,
    required this.friendName,
  }) : super(key: key);

  @override
  State<PersonalChatPage> createState() => _PersonalChatPageState();
}

class _PersonalChatPageState extends State<PersonalChatPage> {
  final TextEditingController _messageController = TextEditingController();

  String getChatRoomId() {
    final ids = [widget.currentUserId, widget.friendUid];
    ids.sort();
    return ids.join('_');
  }

  void sendMessage({String? text, String? base64Image}) async {
    if ((text == null || text.trim().isEmpty) && base64Image == null) return;

    final chatRoomId = getChatRoomId();

    await FirebaseFirestore.instance
        .collection('personal_chats')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'message': base64Image ?? text,
      'type': base64Image != null ? 'image' : 'text',
      'senderId': widget.currentUserId,
      'receiverId': widget.friendUid,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'sent',
    });

    _messageController.clear();
  }

  void pickImageAndSend(ImageSource source) async {
    String? base64Image;
    if (source == ImageSource.camera) {
      base64Image = await ImagePickerHelper.pickImageFromCamera();
    } else {
      base64Image = await ImagePickerHelper.pickImageFromGallery();
    }

    if (base64Image != null) {
      sendMessage(base64Image: base64Image);
    }
  }

  String formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return "Unknown";
    final dateTime = timestamp.toDate();
    final now = DateTime.now();

    final isToday = dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year;

    final timeString =
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";

    return isToday
        ? "Last seen today at $timeString"
        : "Last seen on ${dateTime.day}/${dateTime.month}/${dateTime.year} at $timeString";
  }

  Future<void> markMessagesAsDelivered(List<QueryDocumentSnapshot> messages) async {
    final chatRoomId = getChatRoomId();
    for (var doc in messages) {
      final data = doc.data() as Map<String, dynamic>;
      final isToMe = data['receiverId'] == widget.currentUserId;

      if (isToMe && data['status'] == 'sent') {
        await FirebaseFirestore.instance
            .collection('personal_chats')
            .doc(chatRoomId)
            .collection('messages')
            .doc(doc.id)
            .update({'status': 'delivered'});
      }
    }
  }

  Future<void> markMessagesAsSeen() async {
    final chatRoomId = getChatRoomId();
    final query = await FirebaseFirestore.instance
        .collection('personal_chats')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiverId', isEqualTo: widget.currentUserId)
        .where('status', isEqualTo: 'delivered')
        .get();

    for (var doc in query.docs) {
      await doc.reference.update({'status': 'seen'});
    }
  }

  @override
  void initState() {
    super.initState();
    markMessagesAsSeen();
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomId = getChatRoomId();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.friendUid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text(widget.friendName);
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.friendName, style: const TextStyle(fontSize: 18)),
                  const Text("Status unavailable",
                      style: TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              );
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final String status = userData['status'] ?? 'offline';
            Timestamp? lastSeen = userData['lastSeen'] as Timestamp?;

            String statusText = "Offline";
            if (status == 'online') {
              statusText = "Online";
            } else if (lastSeen != null) {
              statusText = formatDateTime(lastSeen);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.friendName, style: const TextStyle(fontSize: 18)),
                Text(statusText,
                    style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('personal_chats')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No messages yet"));
                }

                final messages = snapshot.data!.docs;
                markMessagesAsDelivered(messages);

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == widget.currentUserId;
                    final isImage = data['type'] == 'image';

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment:
                        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue[100] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: isImage
                                ? Image.memory(
                              ImagePickerHelper.decodeBase64Image(data['message']),
                              width: 200,
                            )
                                : Text(data['message'] ?? ''),
                          ),
                          if (isMe)
                            Padding(
                              padding: const EdgeInsets.only(right: 10, top: 2),
                              child: Text(
                                data['status'] ?? 'sent',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () => pickImageAndSend(ImageSource.camera),
                ),
                IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: () => pickImageAndSend(ImageSource.gallery),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: "Type a message..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => sendMessage(text: _messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}