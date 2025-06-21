// import 'package:chat_app/group_chats/create_group/add_members.dart';
// import 'package:chat_app/group_chats/group_chat_room.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class GroupChatHomeScreen extends StatefulWidget {
//   const GroupChatHomeScreen({Key? key}) : super(key: key);
//
//   @override
//   _GroupChatHomeScreenState createState() => _GroupChatHomeScreenState();
// }
//
// class _GroupChatHomeScreenState extends State<GroupChatHomeScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   bool isLoading = true;
//
//   List groupList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     getAvailableGroups();
//   }
//
//   void getAvailableGroups() async {
//     String uid = _auth.currentUser!.uid;
//
//     await _firestore
//         .collection('users')
//         .doc(uid)
//         .collection('groups')
//         .get()
//         .then((value) {
//       setState(() {
//         groupList = value.docs;
//         isLoading = false;
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       appBar: AppBar(title: Text("Groups")),
//       body: isLoading
//           ? Container(
//               height: size.height,
//               width: size.width,
//               alignment: Alignment.center,
//               child: CircularProgressIndicator(),
//             )
//           : ListView.builder(
//               itemCount: groupList.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   onTap: () => Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (_) => GroupChatRoom(
//                         groupName: groupList[index]['name'],
//                         groupChatId: groupList[index]['id'],
//                       ),
//                     ),
//                   ),
//                   leading: Icon(Icons.group),
//                   title: Text(groupList[index]['name']),
//                 );
//               },
//             ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.create),
//         onPressed: () => Navigator.of(
//           context,
//         ).push(MaterialPageRoute(builder: (_) => AddMembersInGroup())),
//         tooltip: "Create Group",
//       ),
//     );
//   }
// }


import 'package:chat_app/group_chats/create_group/add_members.dart';
import 'package:chat_app/group_chats/group_chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupChatHomeScreen extends StatefulWidget {
  const GroupChatHomeScreen({Key? key}) : super(key: key);

  @override
  State<GroupChatHomeScreen> createState() => _GroupChatHomeScreenState();
}

class _GroupChatHomeScreenState extends State<GroupChatHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = true;
  List<Map<String, dynamic>> groupList = [];

  @override
  void initState() {
    super.initState();
    getAvailableGroups();
  }

  Future<void> getAvailableGroups() async {
    try {
      final String uid = _auth.currentUser?.uid ?? "";

      if (uid.isEmpty) {
        throw Exception("User not logged in");
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('groups')
          .get();

      final List<Map<String, dynamic>> groups = snapshot.docs.map((doc) {
        return {
          'name': doc['name'] ?? 'Unnamed Group',
          'id': doc['id'] ?? doc.id,
        };
      }).toList();

      if (mounted) {
        setState(() {
          groupList = groups;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print("Error fetching groups: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load groups")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Groups"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : groupList.isEmpty
          ? Center(child: Text("No groups found"))
          : ListView.builder(
        itemCount: groupList.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GroupChatRoom(
                    groupName: groupList[index]['name'],
                    groupChatId: groupList[index]['id'],
                  ),
                ),
              );
            },
            leading: const Icon(Icons.group),
            title: Text(groupList[index]['name']),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Create Group",
        child: const Icon(Icons.create),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddMembersInGroup(),
            ),
          );
        },
      ),
    );
  }
}
