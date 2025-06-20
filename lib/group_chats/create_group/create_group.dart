// import 'package:chat_app/Screens/HomeScreen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
//
// class CreateGroup extends StatefulWidget {
//   final List<Map<String, dynamic>> membersList;
//
//   const CreateGroup({required this.membersList, Key? key}) : super(key: key);
//
//   @override
//   State<CreateGroup> createState() => _CreateGroupState();
// }
//
// class _CreateGroupState extends State<CreateGroup> {
//   final TextEditingController _groupName = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   bool isLoading = false;
//
//   void createGroup() async {
//     setState(() {
//       isLoading = true;
//     });
//
//     String groupId = Uuid().v1();
//
//     await _firestore.collection('groups').doc(groupId).set({
//       "members": widget.membersList,
//       "id": groupId,
//     });
//
//     for (int i = 0; i < widget.membersList.length; i++) {
//       String uid = widget.membersList[i]['uid'];
//
//       await _firestore
//           .collection('users')
//           .doc(uid)
//           .collection('groups')
//           .doc(groupId)
//           .set({"name": _groupName.text, "id": groupId});
//     }
//
//     await _firestore.collection('groups').doc(groupId).collection('chats').add({
//       "message": "${_auth.currentUser!.displayName} Created This Group.",
//       "type": "notify",
//     });
//
//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (_) => HomeScreen()),
//       (route) => false,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       appBar: AppBar(title: Text("Group Name")),
//       body: isLoading
//           ? Container(
//               height: size.height,
//               width: size.width,
//               alignment: Alignment.center,
//               child: CircularProgressIndicator(),
//             )
//           : Column(
//               children: [
//                 SizedBox(height: size.height / 10),
//                 Container(
//                   height: size.height / 14,
//                   width: size.width,
//                   alignment: Alignment.center,
//                   child: Container(
//                     height: size.height / 14,
//                     width: size.width / 1.15,
//                     child: TextField(
//                       controller: _groupName,
//                       decoration: InputDecoration(
//                         hintText: "Enter Group Name",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: size.height / 50),
//                 ElevatedButton(
//                   onPressed: createGroup,
//                   child: Text("Create Group"),
//                 ),
//               ],
//             ),
//     );
//   }
// }
//
//
// //



import 'package:chat_app/Screens/HomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CreateGroup extends StatefulWidget {
  final List<Map<String, dynamic>> membersList;

  const CreateGroup({required this.membersList, Key? key}) : super(key: key);

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final TextEditingController _groupNameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  void createGroup() async {
    final String groupName = _groupNameController.text.trim();

    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a group name.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String groupId = const Uuid().v1();

      // Add current user to the group if not already
      final currentUser = _auth.currentUser;
      final currentUserMap = {
        "name": currentUser?.displayName ?? "Unknown",
        "uid": currentUser?.uid,
        "email": currentUser?.email,
        "isAdmin": true,
      };

      if (!widget.membersList.any((member) => member['uid'] == currentUser?.uid)) {
        widget.membersList.add(currentUserMap);
      }

      // Save group to Firestore
      await _firestore.collection('groups').doc(groupId).set({
        "members": widget.membersList,
        "id": groupId,
        "name": groupName,
        "createdBy": currentUser?.uid,
        "createdAt": FieldValue.serverTimestamp(),
      });

      // Add group to each member's user document
      for (var member in widget.membersList) {
        String uid = member['uid'];
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('groups')
            .doc(groupId)
            .set({
          "name": groupName,
          "id": groupId,
        });
      }

      // Add first notification message in the group chat
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('chats')
          .add({
        "message": "${currentUser?.displayName} created this group.",
        "type": "notify",
        "timestamp": FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create group: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text("Create Group")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.1),
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                hintText: "Enter Group Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: createGroup,
              child: const Text("Create Group"),
            ),
          ],
        ),
      ),
    );
  }
}
