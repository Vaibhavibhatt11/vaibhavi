// import 'package:chat_app/group_chats/group_info.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class GroupChatRoom extends StatelessWidget {
//   final String groupChatId, groupName;
//
//   GroupChatRoom({required this.groupName, required this.groupChatId, Key? key})
//       : super(key: key);
//
//   final TextEditingController _message = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   void onSendMessage() async {
//     if (_message.text.isNotEmpty) {
//       Map<String, dynamic> chatData = {
//         "sendBy": _auth.currentUser!.displayName,
//         "message": _message.text,
//         "type": "text",
//         "time": FieldValue.serverTimestamp(),
//       };
//
//       _message.clear();
//
//       await _firestore
//           .collection('groups')
//           .doc(groupChatId)
//           .collection('chats')
//           .add(chatData);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(groupName),
//         actions: [
//           IconButton(
//             onPressed: () => Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (_) =>
//                     GroupInfo(groupName: groupName, groupId: groupChatId),
//               ),
//             ),
//             icon: Icon(Icons.more_vert),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               height: size.height / 1.27,
//               width: size.width,
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: _firestore
//                     .collection('groups')
//                     .doc(groupChatId)
//                     .collection('chats')
//                     .orderBy('time')
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData) {
//                     return ListView.builder(
//                       itemCount: snapshot.data!.docs.length,
//                       itemBuilder: (context, index) {
//                         Map<String, dynamic> chatMap =
//                             snapshot.data!.docs[index].data()
//                                 as Map<String, dynamic>;
//
//                         return messageTile(size, chatMap);
//                       },
//                     );
//                   } else {
//                     return Container();
//                   }
//                 },
//               ),
//             ),
//             Container(
//               height: size.height / 10,
//               width: size.width,
//               alignment: Alignment.center,
//               child: Container(
//                 height: size.height / 12,
//                 width: size.width / 1.1,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       height: size.height / 17,
//                       width: size.width / 1.3,
//                       child: TextField(
//                         controller: _message,
//                         decoration: InputDecoration(
//                           suffixIcon: IconButton(
//                             onPressed: () {},
//                             icon: Icon(Icons.photo),
//                           ),
//                           hintText: "Send Message",
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.send),
//                       onPressed: onSendMessage,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget messageTile(Size size, Map<String, dynamic> chatMap) {
//     return Builder(
//       builder: (_) {
//         if (chatMap['type'] == "text") {
//           return Container(
//             width: size.width,
//             alignment: chatMap['sendBy'] == _auth.currentUser!.displayName
//                 ? Alignment.centerRight
//                 : Alignment.centerLeft,
//             child: Container(
//               padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
//               margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(15),
//                 color: Colors.blue,
//               ),
//               child: Column(
//                 children: [
//                   Text(
//                     chatMap['sendBy'],
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.white,
//                     ),
//                   ),
//                   SizedBox(height: size.height / 200),
//                   Text(
//                     chatMap['message'],
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         } else if (chatMap['type'] == "img") {
//           return Container(
//             width: size.width,
//             alignment: chatMap['sendBy'] == _auth.currentUser!.displayName
//                 ? Alignment.centerRight
//                 : Alignment.centerLeft,
//             child: Container(
//               padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//               margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//               height: size.height / 2,
//               child: Image.network(chatMap['message']),
//             ),
//           );
//         } else if (chatMap['type'] == "notify") {
//           return Container(
//             width: size.width,
//             alignment: Alignment.center,
//             child: Container(
//               padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//               margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(5),
//                 color: Colors.black38,
//               ),
//               child: Text(
//                 chatMap['message'],
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           );
//         } else {
//           return SizedBox();
//         }
//       },
//     );
//   }
// }


import 'dart:io';

import 'package:chat_app/group_chats/group_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class GroupChatRoom extends StatefulWidget {
  final String groupChatId, groupName;

  const GroupChatRoom({
    required this.groupName,
    required this.groupChatId,
    Key? key,
  }) : super(key: key);

  @override
  State<GroupChatRoom> createState() => _GroupChatRoomState();
}

class _GroupChatRoomState extends State<GroupChatRoom> {
  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  Future<void> onSendMessage() async {
    if (_message.text.trim().isNotEmpty) {
      final chatData = {
        "sendBy": _auth.currentUser?.displayName ?? "Unknown",
        "message": _message.text.trim(),
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();
      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .add(chatData);

      scrollToBottom();
    }
  }

  Future<void> sendImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('groupChats/${widget.groupChatId}/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putFile(File(picked.path));
      final url = await ref.getDownloadURL();

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .add({
        "sendBy": _auth.currentUser?.displayName ?? "Unknown",
        "message": url,
        "type": "img",
        "time": FieldValue.serverTimestamp(),
      });

      scrollToBottom();
    }
  }

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GroupInfo(
                  groupName: widget.groupName,
                  groupId: widget.groupChatId,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('groups')
                  .doc(widget.groupChatId)
                  .collection('chats')
                  .orderBy('time')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No messages yet"));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: docs.length,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  itemBuilder: (context, index) {
                    final chatMap =
                    docs[index].data()! as Map<String, dynamic>;
                    return messageTile(size, chatMap);
                  },
                );
              },
            ),
          ),
          chatInputBar(size),
        ],
      ),
    );
  }

  Widget chatInputBar(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _message,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.symmetric(horizontal: 14),
                suffixIcon: IconButton(
                  icon: Icon(Icons.photo),
                  onPressed: sendImage,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blueAccent),
            onPressed: onSendMessage,
          ),
        ],
      ),
    );
  }

  Widget messageTile(Size size, Map<String, dynamic> chatMap) {
    final isMe = chatMap['sendBy'] == _auth.currentUser?.displayName;
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final color = isMe ? Colors.blue : Colors.grey[600];

    if (chatMap['type'] == 'text') {
      return Container(
        alignment: alignment,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                chatMap['sendBy'] ?? 'Unknown',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              SizedBox(height: 4),
              Text(
                chatMap['message'] ?? '',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    } else if (chatMap['type'] == 'img') {
      return Container(
        alignment: alignment,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 6),
          constraints: BoxConstraints(maxHeight: size.height / 2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(chatMap['message']),
          ),
        ),
      );
    } else if (chatMap['type'] == 'notify') {
      return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            chatMap['message'] ?? '',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
