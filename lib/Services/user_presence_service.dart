// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class UserPresenceService {
//   final String? uid = FirebaseAuth.instance.currentUser?.uid;
//
//   void updatePresence(String status) {
//     if (uid != null) {
//       FirebaseFirestore.instance.collection('users').doc(uid).update({
//         'status': status,
//         'lastSeen': DateTime.now(),
//       });
//     }
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPresenceService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updatePresence(String status) async {
    try {
      final User? user = _auth.currentUser;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'status': status,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      } else {
        print("No user is signed in.");
      }
    } catch (e) {
      print("Failed to update user presence: $e");
    }
  }
}
