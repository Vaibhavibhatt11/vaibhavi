// import 'package:chat_app/group_chats/create_group/create_group.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class AddMembersInGroup extends StatefulWidget {
//   const AddMembersInGroup({Key? key}) : super(key: key);
//
//   @override
//   State<AddMembersInGroup> createState() => _AddMembersInGroupState();
// }
//
// class _AddMembersInGroupState extends State<AddMembersInGroup> {
//   final TextEditingController _search = TextEditingController();
//   FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   FirebaseAuth _auth = FirebaseAuth.instance;
//   List<Map<String, dynamic>> membersList = [];
//   bool isLoading = false;
//   Map<String, dynamic>? userMap;
//
//   @override
//   void initState() {
//     super.initState();
//     getCurrentUserDetails();
//   }
//
//   void getCurrentUserDetails() async {
//     await _firestore.collection('users').doc(_auth.currentUser!.uid).get().then(
//       (map) {
//         setState(() {
//           membersList.add({
//             "name": map['name'],
//             "email": map['email'],
//             "uid": map['uid'],
//             "isAdmin": true,
//           });
//         });
//       },
//     );
//   }
//
//   void onSearch() async {
//     setState(() {
//       isLoading = true;
//     });
//
//     await _firestore
//         .collection('users')
//         .where("email", isEqualTo: _search.text)
//         .get()
//         .then((value) {
//       setState(() {
//         userMap = value.docs[0].data();
//         isLoading = false;
//       });
//       print(userMap);
//     });
//   }
//
//   void onResultTap() {
//     bool isAlreadyExist = false;
//
//     for (int i = 0; i < membersList.length; i++) {
//       if (membersList[i]['uid'] == userMap!['uid']) {
//         isAlreadyExist = true;
//       }
//     }
//
//     if (!isAlreadyExist) {
//       setState(() {
//         membersList.add({
//           "name": userMap!['name'],
//           "email": userMap!['email'],
//           "uid": userMap!['uid'],
//           "isAdmin": false,
//         });
//
//         userMap = null;
//       });
//     }
//   }
//
//   void onRemoveMembers(int index) {
//     if (membersList[index]['uid'] != _auth.currentUser!.uid) {
//       setState(() {
//         membersList.removeAt(index);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       appBar: AppBar(title: Text("Add Members")),
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Flexible(
//               child: ListView.builder(
//                 itemCount: membersList.length,
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     onTap: () => onRemoveMembers(index),
//                     leading: Icon(Icons.account_circle),
//                     title: Text(membersList[index]['name']),
//                     subtitle: Text(membersList[index]['email']),
//                     trailing: Icon(Icons.close),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: size.height / 20),
//             Container(
//               height: size.height / 14,
//               width: size.width,
//               alignment: Alignment.center,
//               child: Container(
//                 height: size.height / 14,
//                 width: size.width / 1.15,
//                 child: TextField(
//                   controller: _search,
//                   decoration: InputDecoration(
//                     hintText: "Search",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: size.height / 50),
//             isLoading
//                 ? Container(
//                     height: size.height / 12,
//                     width: size.height / 12,
//                     alignment: Alignment.center,
//                     child: CircularProgressIndicator(),
//                   )
//                 : ElevatedButton(onPressed: onSearch, child: Text("Search")),
//             userMap != null
//                 ? ListTile(
//                     onTap: onResultTap,
//                     leading: Icon(Icons.account_box),
//                     title: Text(userMap!['name']),
//                     subtitle: Text(userMap!['email']),
//                     trailing: Icon(Icons.add),
//                   )
//                 : SizedBox(),
//           ],
//         ),
//       ),
//       floatingActionButton: membersList.length >= 2
//           ? FloatingActionButton(
//               child: Icon(Icons.forward),
//               onPressed: () => Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (_) => CreateGroup(membersList: membersList),
//                 ),
//               ),
//             )
//           : SizedBox(),
//     );
//   }
// }


import 'package:chat_app/group_chats/create_group/create_group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddMembersInGroup extends StatefulWidget {
  const AddMembersInGroup({Key? key}) : super(key: key);

  @override
  State<AddMembersInGroup> createState() => _AddMembersInGroupState();
}

class _AddMembersInGroupState extends State<AddMembersInGroup> {
  final TextEditingController _search = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> membersList = [];
  Map<String, dynamic>? userMap;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  void getCurrentUserDetails() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final snapshot = await _firestore.collection('users').doc(currentUser.uid).get();
      setState(() {
        membersList.add({
          "name": snapshot['name'],
          "email": snapshot['email'],
          "uid": snapshot['uid'],
          "isAdmin": true,
        });
      });
    }
  }

  void onSearch() async {
    final searchEmail = _search.text.trim();

    if (searchEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter an email."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      userMap = null;
    });

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where("email", isEqualTo: searchEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          userMap = querySnapshot.docs.first.data();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No user found."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Search Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void onResultTap() {
    if (userMap == null) return;

    bool alreadyAdded = membersList.any((member) => member['uid'] == userMap!['uid']);

    if (!alreadyAdded) {
      setState(() {
        membersList.add({
          "name": userMap!['name'],
          "email": userMap!['email'],
          "uid": userMap!['uid'],
          "isAdmin": false,
        });
        userMap = null;
        _search.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User is already added."),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void onRemoveMembers(int index) {
    if (membersList[index]['uid'] != _auth.currentUser!.uid) {
      setState(() {
        membersList.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text("Add Members")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListView.builder(
              itemCount: membersList.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () => onRemoveMembers(index),
                  leading: const Icon(Icons.account_circle),
                  title: Text(membersList[index]['name']),
                  subtitle: Text(membersList[index]['email']),
                  trailing: const Icon(Icons.close),
                );
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: "Search by email",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: onSearch,
              child: const Text("Search"),
            ),
            const SizedBox(height: 10),
            userMap != null
                ? ListTile(
              onTap: onResultTap,
              leading: const Icon(Icons.account_box),
              title: Text(userMap!['name']),
              subtitle: Text(userMap!['email']),
              trailing: const Icon(Icons.add),
            )
                : const SizedBox.shrink(),
          ],
        ),
      ),
      floatingActionButton: membersList.length >= 2
          ? FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreateGroup(membersList: membersList),
            ),
          );
        },
        child: const Icon(Icons.forward),
      )
          : null,
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }
}
