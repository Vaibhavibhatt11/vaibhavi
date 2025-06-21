// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:uuid/uuid.dart';
//
// class ChatRoom extends StatelessWidget {
//   final Map<String, dynamic> userMap;
//   final String chatRoomId;
//
//   ChatRoom({required this.chatRoomId, required this.userMap});
//
//   final TextEditingController _message = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   File? imageFile;
//
//   Future getImage() async {
//     ImagePicker _picker = ImagePicker();
//
//     await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
//       if (xFile != null) {
//         imageFile = File(xFile.path);
//         uploadImage();
//       }
//     });
//   }
//
//   Future uploadImage() async {
//     String fileName = Uuid().v1();
//     int status = 1;
//
//     await _firestore
//         .collection('chatroom')
//         .doc(chatRoomId)
//         .collection('chats')
//         .doc(fileName)
//         .set({
//       "sendby": _auth.currentUser!.displayName,
//       "message": "",
//       "type": "img",
//       "time": FieldValue.serverTimestamp(),
//     });
//
//     var ref =
//         FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");
//
//     var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
//       await _firestore
//           .collection('chatroom')
//           .doc(chatRoomId)
//           .collection('chats')
//           .doc(fileName)
//           .delete();
//
//       status = 0;
//     });
//
//     if (status == 1) {
//       String imageUrl = await uploadTask.ref.getDownloadURL();
//
//       await _firestore
//           .collection('chatroom')
//           .doc(chatRoomId)
//           .collection('chats')
//           .doc(fileName)
//           .update({"message": imageUrl});
//
//       print(imageUrl);
//     }
//   }
//
//   void onSendMessage() async {
//     if (_message.text.isNotEmpty) {
//       Map<String, dynamic> messages = {
//         "sendby": _auth.currentUser!.displayName,
//         "message": _message.text,
//         "type": "text",
//         "time": FieldValue.serverTimestamp(),
//       };
//
//       _message.clear();
//       await _firestore
//           .collection('chatroom')
//           .doc(chatRoomId)
//           .collection('chats')
//           .add(messages);
//     } else {
//       print("Enter Some Text");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: StreamBuilder<DocumentSnapshot>(
//           stream:
//               _firestore.collection("users").doc(userMap['uid']).snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.data != null) {
//               return Container(
//                 child: Column(
//                   children: [
//                     Text(userMap['name']),
//                     Text(
//                       snapshot.data!['status'],
//                       style: TextStyle(fontSize: 14),
//                     ),
//                   ],
//                 ),
//               );
//             } else {
//               return Container();
//             }
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               height: size.height / 1.25,
//               width: size.width,
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: _firestore
//                     .collection('chatroom')
//                     .doc(chatRoomId)
//                     .collection('chats')
//                     .orderBy("time", descending: false)
//                     .snapshots(),
//                 builder: (BuildContext context,
//                     AsyncSnapshot<QuerySnapshot> snapshot) {
//                   if (snapshot.data != null) {
//                     return ListView.builder(
//                       itemCount: snapshot.data!.docs.length,
//                       itemBuilder: (context, index) {
//                         Map<String, dynamic> map = snapshot.data!.docs[index]
//                             .data() as Map<String, dynamic>;
//                         return messages(size, map, context);
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
//                             suffixIcon: IconButton(
//                               onPressed: () => getImage(),
//                               icon: Icon(Icons.photo),
//                             ),
//                             hintText: "Send Message",
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             )),
//                       ),
//                     ),
//                     IconButton(
//                         icon: Icon(Icons.send), onPressed: onSendMessage),
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
//   Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
//     return map['type'] == "text"
//         ? Container(
//             width: size.width,
//             alignment: map['sendby'] == _auth.currentUser!.displayName
//                 ? Alignment.centerRight
//                 : Alignment.centerLeft,
//             child: Container(
//               padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//               margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(15),
//                 color: Colors.blue,
//               ),
//               child: Text(
//                 map['message'],
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           )
//         : Container(
//             height: size.height / 2.5,
//             width: size.width,
//             padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
//             alignment: map['sendby'] == _auth.currentUser!.displayName
//                 ? Alignment.centerRight
//                 : Alignment.centerLeft,
//             child: InkWell(
//               onTap: () => Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (_) => ShowImage(
//                     imageUrl: map['message'],
//                   ),
//                 ),
//               ),
//               child: Container(
//                 height: size.height / 2.5,
//                 width: size.width / 2,
//                 decoration: BoxDecoration(border: Border.all()),
//                 alignment: map['message'] != "" ? null : Alignment.center,
//                 child: map['message'] != ""
//                     ? Image.network(
//                         map['message'],
//                         fit: BoxFit.cover,
//                       )
//                     : CircularProgressIndicator(),
//               ),
//             ),
//           );
//   }
// }
//
// class ShowImage extends StatelessWidget {
//   final String imageUrl;
//
//   const ShowImage({required this.imageUrl, Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       body: Container(
//         height: size.height,
//         width: size.width,
//         color: Colors.black,
//         child: Image.network(imageUrl),
//       ),
//     );
//   }
// }


import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatRoom extends StatefulWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;

  const ChatRoom({required this.chatRoomId, required this.userMap, Key? key})
      : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? imageFile;
  bool isUploadingImage = false;

  Future<void> getImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? xFile = await picker.pickImage(source: ImageSource.gallery);

    if (xFile != null) {
      setState(() {
        imageFile = File(xFile.path);
        isUploadingImage = true;
      });
      await uploadImage();
    }
  }

  Future<void> uploadImage() async {
    final String fileName = const Uuid().v1();

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('images')
          .child('$fileName.jpg');

      // Pre-save chat message with empty URL
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .set({
        "sendby": _auth.currentUser?.displayName ?? 'Unknown',
        "message": "",
        "type": "img",
        "time": FieldValue.serverTimestamp(),
      });

      await ref.putFile(imageFile!);

      final String imageUrl = await ref.getDownloadURL();

      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});
    } catch (e) {
      // Remove failed chat message
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .delete();
      print("Image upload error: $e");
    } finally {
      setState(() {
        isUploadingImage = false;
      });
    }
  }

  void onSendMessage() async {
    if (_message.text.trim().isNotEmpty) {
      final messageData = {
        "sendby": _auth.currentUser?.displayName ?? 'Unknown',
        "message": _message.text.trim(),
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();

      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .add(messageData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: _firestore
              .collection("users")
              .doc(widget.userMap['uid'])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.userMap['name']),
                  Text(
                    snapshot.data!['status'] ?? "Offline",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              );
            }
            return const Text("Loading...");
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chatroom')
                  .doc(widget.chatRoomId)
                  .collection('chats')
                  .orderBy("time", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final map = snapshot.data!.docs[index].data()
                    as Map<String, dynamic>;
                    return messages(size, map, context);
                  },
                );
              },
            ),
          ),
          if (isUploadingImage)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _message,
                    decoration: InputDecoration(
                      hintText: "Send Message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.photo),
                        onPressed: getImage,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: onSendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
    final isSender = map['sendby'] == _auth.currentUser?.displayName;

    return map['type'] == "text"
        ? Container(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSender ? Colors.blue : Colors.grey[600],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        map['message'],
        style: const TextStyle(color: Colors.white),
      ),
    )
        : Container(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          if (map['message'] != "") {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ShowImage(imageUrl: map['message']),
              ),
            );
          }
        },
        child: Container(
          width: size.width / 2,
          height: size.height / 2.5,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
          ),
          child: map['message'] != ""
              ? Image.network(map['message'], fit: BoxFit.cover)
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.network(
          imageUrl,
          height: size.height,
          width: size.width,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
