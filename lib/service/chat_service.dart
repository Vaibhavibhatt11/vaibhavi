import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// ------------------ PERSONAL CHAT ------------------ ///

  Stream<QuerySnapshot> getPersonalMessages(String senderId, String receiverId) {
    String chatId = _getChatId(senderId, receiverId);
    return _firestore
        .collection('personal_chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  Future<void> sendTextMessage({
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    String chatId = _getChatId(senderId, receiverId);
    await _firestore.collection('personal_chats').doc(chatId).collection('messages').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'type': 'text',
      'timestamp': FieldValue.serverTimestamp(),
      'isSeen': false,
    });

    await _firestore.collection('personal_chats').doc(chatId).set({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSender': senderId,
    }, SetOptions(merge: true));
  }

  Future<void> sendImageMessage({
    required String senderId,
    required String receiverId,
    required File image,
  }) async {
    String chatId = _getChatId(senderId, receiverId);
    String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    UploadTask uploadTask = _storage.ref().child('chat_images/$chatId/$fileName').putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();

    await _firestore.collection('personal_chats').doc(chatId).collection('messages').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'text': imageUrl,
      'type': 'image',
      'timestamp': FieldValue.serverTimestamp(),
      'isSeen': false,
    });

    await _firestore.collection('personal_chats').doc(chatId).set({
      'lastMessage': '[Image]',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSender': senderId,
    }, SetOptions(merge: true));
  }

  /// ------------------ GROUP CHAT ------------------ ///

  Stream<QuerySnapshot> getGroupMessages(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  Future<void> sendGroupTextMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    await _firestore.collection('groups').doc(groupId).collection('messages').add({
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'type': 'text',
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('groups').doc(groupId).update({
      'recentMessage': text,
      'recentMessageSender': senderName,
      'recentMessageTime': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendGroupImageMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    required File image,
  }) async {
    String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    UploadTask uploadTask = _storage.ref().child('group_images/$groupId/$fileName').putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();

    await _firestore.collection('groups').doc(groupId).collection('messages').add({
      'senderId': senderId,
      'senderName': senderName,
      'text': imageUrl,
      'type': 'image',
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('groups').doc(groupId).update({
      'recentMessage': '[Image]',
      'recentMessageSender': senderName,
      'recentMessageTime': FieldValue.serverTimestamp(),
    });
  }

  /// Utility for personal chat
  String _getChatId(String id1, String id2) {
    return id1.hashCode <= id2.hashCode ? '${id1}_$id2' : '${id2}_$id1';
  }
}
