import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageBubble extends StatelessWidget {
  final String messageId;
  final String chatRoomId;
  final String text;
  final String senderId;
  final String currentUserId;
  final Map<String, dynamic>? reactions;

  MessageBubble({
    required this.messageId,
    required this.chatRoomId,
    required this.text,
    required this.senderId,
    required this.currentUserId,
    this.reactions,
  });

  void _addReaction(String emoji) {
    final messageRef = FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId);

    messageRef.set({
      'reactions.$emoji': FieldValue.arrayUnion([currentUserId]),
    }, SetOptions(merge: true));
  }

  void _showEmojiPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ["❤️", "😂", "👍", "😮", "😢"].map((emoji) {
            return IconButton(
              onPressed: () {
                _addReaction(emoji);
                Navigator.pop(context);
              },
              icon: Text(emoji, style: TextStyle(fontSize: 24)),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showEmojiPicker(context),
      child: Column(
        crossAxisAlignment: currentUserId == senderId
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: currentUserId == senderId
                  ? Colors.blue[100]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text),
                if (reactions != null && reactions!.isNotEmpty)
                  Wrap(
                    children: reactions!.entries.map((entry) {
                      final emoji = entry.key;
                      final users = entry.value as List<dynamic>;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          "$emoji ${users.length}",
                          style: TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
