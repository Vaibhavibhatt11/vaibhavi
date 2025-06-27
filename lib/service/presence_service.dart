import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PresenceService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static void setUserStatus(String status) {
    String uid = _auth.currentUser!.uid;
    _firestore.collection('users').doc(uid).update({
      'status': status,
      'lastSeen': DateTime.now(),
    });
  }

  static void monitorConnection() {
    Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) {
            if (result != ConnectivityResult.none) {
              setUserStatus("online");
            } else {
              setUserStatus("offline");
            }
          }
          as void Function(List<ConnectivityResult> event)?,
    );
  }
}
