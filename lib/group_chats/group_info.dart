// import 'package:chat_app/Screens/HomeScreen.dart';
// import 'package:chat_app/group_chats/add_members.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class GroupInfo extends StatefulWidget {
//   final String groupId, groupName;
//   const GroupInfo({required this.groupId, required this.groupName, Key? key})
//       : super(key: key);
//
//   @override
//   State<GroupInfo> createState() => _GroupInfoState();
// }
//
// class _GroupInfoState extends State<GroupInfo> {
//   List membersList = [];
//   bool isLoading = true;
//
//   FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   FirebaseAuth _auth = FirebaseAuth.instance;
//
//   @override
//   void initState() {
//     super.initState();
//
//     getGroupDetails();
//   }
//
//   Future getGroupDetails() async {
//     await _firestore.collection('groups').doc(widget.groupId).get().then((
//       chatMap,
//     ) {
//       membersList = chatMap['members'];
//       print(membersList);
//       isLoading = false;
//       setState(() {});
//     });
//   }
//
//   bool checkAdmin() {
//     bool isAdmin = false;
//
//     membersList.forEach((element) {
//       if (element['uid'] == _auth.currentUser!.uid) {
//         isAdmin = element['isAdmin'];
//       }
//     });
//     return isAdmin;
//   }
//
//   Future removeMembers(int index) async {
//     String uid = membersList[index]['uid'];
//
//     setState(() {
//       isLoading = true;
//       membersList.removeAt(index);
//     });
//
//     await _firestore
//         .collection('groups')
//         .doc(widget.groupId)
//         .update({"members": membersList}).then((value) async {
//       await _firestore
//           .collection('users')
//           .doc(uid)
//           .collection('groups')
//           .doc(widget.groupId)
//           .delete();
//
//       setState(() {
//         isLoading = false;
//       });
//     });
//   }
//
//   void showDialogBox(int index) {
//     if (checkAdmin()) {
//       if (_auth.currentUser!.uid != membersList[index]['uid']) {
//         showDialog(
//           context: context,
//           builder: (context) {
//             return AlertDialog(
//               content: ListTile(
//                 onTap: () => removeMembers(index),
//                 title: Text("Remove This Member"),
//               ),
//             );
//           },
//         );
//       }
//     }
//   }
//
//   Future onLeaveGroup() async {
//     if (!checkAdmin()) {
//       setState(() {
//         isLoading = true;
//       });
//
//       for (int i = 0; i < membersList.length; i++) {
//         if (membersList[i]['uid'] == _auth.currentUser!.uid) {
//           membersList.removeAt(i);
//         }
//       }
//
//       await _firestore.collection('groups').doc(widget.groupId).update({
//         "members": membersList,
//       });
//
//       await _firestore
//           .collection('users')
//           .doc(_auth.currentUser!.uid)
//           .collection('groups')
//           .doc(widget.groupId)
//           .delete();
//
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (_) => HomeScreen()),
//         (route) => false,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;
//
//     return SafeArea(
//       child: Scaffold(
//         body: isLoading
//             ? Container(
//                 height: size.height,
//                 width: size.width,
//                 alignment: Alignment.center,
//                 child: CircularProgressIndicator(),
//               )
//             : SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Align(alignment: Alignment.centerLeft, child: BackButton()),
//                     Container(
//                       height: size.height / 8,
//                       width: size.width / 1.1,
//                       child: Row(
//                         children: [
//                           Container(
//                             height: size.height / 11,
//                             width: size.height / 11,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.grey,
//                             ),
//                             child: Icon(
//                               Icons.group,
//                               color: Colors.white,
//                               size: size.width / 10,
//                             ),
//                           ),
//                           SizedBox(width: size.width / 20),
//                           Expanded(
//                             child: Container(
//                               child: Text(
//                                 widget.groupName,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: TextStyle(
//                                   fontSize: size.width / 16,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     //
//                     SizedBox(height: size.height / 20),
//
//                     Container(
//                       width: size.width / 1.1,
//                       child: Text(
//                         "${membersList.length} Members",
//                         style: TextStyle(
//                           fontSize: size.width / 20,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//
//                     SizedBox(height: size.height / 20),
//
//                     // Members Name
//                     checkAdmin()
//                         ? ListTile(
//                             onTap: () => Navigator.of(context).push(
//                               MaterialPageRoute(
//                                 builder: (_) => AddMembersINGroup(
//                                   groupChatId: widget.groupId,
//                                   name: widget.groupName,
//                                   membersList: membersList,
//                                 ),
//                               ),
//                             ),
//                             leading: Icon(Icons.add),
//                             title: Text(
//                               "Add Members",
//                               style: TextStyle(
//                                 fontSize: size.width / 22,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           )
//                         : SizedBox(),
//
//                     Flexible(
//                       child: ListView.builder(
//                         itemCount: membersList.length,
//                         shrinkWrap: true,
//                         physics: NeverScrollableScrollPhysics(),
//                         itemBuilder: (context, index) {
//                           return ListTile(
//                             onTap: () => showDialogBox(index),
//                             leading: Icon(Icons.account_circle),
//                             title: Text(
//                               membersList[index]['name'],
//                               style: TextStyle(
//                                 fontSize: size.width / 22,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             subtitle: Text(membersList[index]['email']),
//                             trailing: Text(
//                               membersList[index]['isAdmin'] ? "Admin" : "",
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//
//                     ListTile(
//                       onTap: onLeaveGroup,
//                       leading: Icon(Icons.logout, color: Colors.redAccent),
//                       title: Text(
//                         "Leave Group",
//                         style: TextStyle(
//                           fontSize: size.width / 22,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.redAccent,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }


import 'package:chat_app/Screens/HomeScreen.dart';
import 'package:chat_app/group_chats/add_members.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  final String groupId, groupName;
  const GroupInfo({required this.groupId, required this.groupName, Key? key}) : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  List membersList = [];
  bool isLoading = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getGroupDetails();
  }

  Future<void> getGroupDetails() async {
    try {
      final chatDoc = await _firestore.collection('groups').doc(widget.groupId).get();

      if (chatDoc.exists) {
        setState(() {
          membersList = List.from(chatDoc.data()?['members'] ?? []);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching group details: $e");
    }
  }

  bool checkAdmin() {
    final currentUser = _auth.currentUser?.uid;
    final user = membersList.firstWhere((element) => element['uid'] == currentUser, orElse: () => null);
    return user != null && user['isAdmin'] == true;
  }

  Future<void> removeMember(int index) async {
    String uid = membersList[index]['uid'];

    setState(() {
      isLoading = true;
    });

    membersList.removeAt(index);

    try {
      await _firestore.collection('groups').doc(widget.groupId).update({"members": membersList});
      await _firestore.collection('users').doc(uid).collection('groups').doc(widget.groupId).delete();
    } catch (e) {
      print("Error removing member: $e");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void confirmRemoveDialog(int index) {
    if (checkAdmin() && _auth.currentUser!.uid != membersList[index]['uid']) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Remove Member"),
          content: Text("Are you sure you want to remove this member?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Remove", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.pop(context);
                removeMember(index);
              },
            ),
          ],
        ),
      );
    }
  }

  Future<void> onLeaveGroup() async {
    final uid = _auth.currentUser!.uid;
    final isUserAdmin = checkAdmin();
    final remainingAdmins = membersList.where((m) => m['isAdmin'] == true).length;

    if (isUserAdmin && remainingAdmins <= 1 && membersList.length > 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You are the only admin. Assign another admin before leaving.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    membersList.removeWhere((element) => element['uid'] == uid);

    try {
      await _firestore.collection('groups').doc(widget.groupId).update({
        "members": membersList,
      });

      await _firestore.collection('users').doc(uid).collection('groups').doc(widget.groupId).delete();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => HomeScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      print("Leave group error: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BackButton(),
              Row(
                children: [
                  CircleAvatar(
                    radius: size.height / 22,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.group, color: Colors.white, size: size.width / 10),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.groupName,
                      style: TextStyle(fontSize: size.width / 16, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "${membersList.length} Members",
                style: TextStyle(fontSize: size.width / 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20),
              if (checkAdmin())
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddMembersInGroup(
                          groupChatId: widget.groupId,
                          name: widget.groupName,
                          membersList: membersList,
                        ),
                      ),
                    );
                  },
                  leading: Icon(Icons.person_add),
                  title: Text("Add Members"),
                ),
              ListView.builder(
                itemCount: membersList.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final member = membersList[index];
                  return ListTile(
                    onTap: () => confirmRemoveDialog(index),
                    leading: Icon(Icons.account_circle),
                    title: Text(member['name']),
                    subtitle: Text(member['email']),
                    trailing: member['isAdmin'] ? Text("Admin", style: TextStyle(color: Colors.green)) : null,
                  );
                },
              ),
              ListTile(
                onTap: onLeaveGroup,
                leading: Icon(Icons.exit_to_app, color: Colors.red),
                title: Text(
                  "Leave Group",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
