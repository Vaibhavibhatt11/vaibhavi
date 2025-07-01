import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection("users");

  final CollectionReference groupCollection =
  FirebaseFirestore.instance.collection("groups");

  // ✅ Save user data
  Future savingUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid,
    });
  }

  // ✅ Get user data by email
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
    await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  // ✅ Get user's group list (stream)
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  // ✅ Create a new group
  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "admins": ["${id}_$userName"],
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });

    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups": FieldValue.arrayUnion(
          ["${groupDocumentReference.id}_$groupName"])
    });
  }

  // ✅ Get chat stream from messages collection
  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  // ✅ Get the group admin
  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot snapshot = await d.get();
    return snapshot['admin'];
  }

  // ✅ Get group members and stream it
  getGroupMembers(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  // ✅ Search group by name
  searchByName(String groupName) {
    return groupCollection.where("groupName", isEqualTo: groupName).get();
  }

  // ✅ Check if user joined a specific group
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocRef = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocRef.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    return groups.contains("${groupId}_$groupName");
  }

  // ✅ Join or leave group
  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    DocumentReference userDocRef = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocRef.get();

    List<dynamic> groups = await documentSnapshot['groups'];

    if (groups.contains("${groupId}_$groupName")) {
      await userDocRef.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupCollection.doc(groupId).update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"]),
        "admins": FieldValue.arrayRemove(["${uid}_$userName"]),
      });
    } else {
      await userDocRef.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupCollection.doc(groupId).update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  // ✅ Send message in group
  sendMessage(String groupId, Map<String, dynamic> chatMessageData) {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }

  // ✅ Remove group member
  Future removeGroupMember(
      String groupId, String memberUid, String memberName) async {
    final String memberKey = "${memberUid}_$memberName";
    final DocumentReference groupDoc = groupCollection.doc(groupId);
    final DocumentReference userDoc = userCollection.doc(memberUid);

    DocumentSnapshot groupSnapshot = await groupDoc.get();
    String groupName = groupSnapshot['groupName'];

    await groupDoc.update({
      "members": FieldValue.arrayRemove([memberKey]),
      "admins": FieldValue.arrayRemove([memberKey]),
    });

    await userDoc.update({
      "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
    });
  }

  // ✅ Promote user to admin
  Future makeAdmin(String groupId, String memberUid, String memberName) async {
    final String memberKey = "${memberUid}_$memberName";
    final DocumentReference groupDoc = groupCollection.doc(groupId);

    await groupDoc.update({
      "admins": FieldValue.arrayUnion([memberKey])
    });
  }
}
