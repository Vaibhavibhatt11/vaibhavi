import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class UserStatusService with WidgetsBindingObserver {
  static final UserStatusService _instance = UserStatusService._internal();
  factory UserStatusService(String uid) => _instance;
  UserStatusService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    _updateUserStatus("Online");
  }

  void disposeService() {
    WidgetsBinding.instance.removeObserver(this);
    _updateUserStatus("Offline");
  }

  void _updateUserStatus(String status) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection("users").doc(user.uid).update({
        "status": status,
        "lastSeen": status == "Offline" ? FieldValue.serverTimestamp() : null,
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_auth.currentUser != null) {
      if (state == AppLifecycleState.resumed) {
        _updateUserStatus("Online");
      } else {
        _updateUserStatus("Offline");
      }
    }
  }

  void dispose() {}
}
