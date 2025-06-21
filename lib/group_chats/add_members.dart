// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class AddMembersINGroup extends StatefulWidget {
//   final String groupChatId, name;
//   final List membersList;
//   const AddMembersINGroup(
//       {required this.name,
//       required this.membersList,
//       required this.groupChatId,
//       Key? key})
//       : super(key: key);
//
//   @override
//   _AddMembersINGroupState createState() => _AddMembersINGroupState();
// }
//
// class _AddMembersINGroupState extends State<AddMembersINGroup> {
//   final TextEditingController _search = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   Map<String, dynamic>? userMap;
//   bool isLoading = false;
//   List membersList = [];
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     membersList = widget.membersList;
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
//   void onAddMembers() async {
//     membersList.add(userMap);
//
//     await _firestore.collection('groups').doc(widget.groupChatId).update({
//       "members": membersList,
//     });
//
//     await _firestore
//         .collection('users')
//         .doc(userMap!['uid'])
//         .collection('groups')
//         .doc(widget.groupChatId)
//         .set({"name": widget.name, "id": widget.groupChatId});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Add Members"),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(
//               height: size.height / 20,
//             ),
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
//             SizedBox(
//               height: size.height / 50,
//             ),
//             isLoading
//                 ? Container(
//                     height: size.height / 12,
//                     width: size.height / 12,
//                     alignment: Alignment.center,
//                     child: CircularProgressIndicator(),
//                   )
//                 : ElevatedButton(
//                     onPressed: onSearch,
//                     child: Text("Search"),
//                   ),
//             userMap != null
//                 ? ListTile(
//                     onTap: onAddMembers,
//                     leading: Icon(Icons.account_box),
//                     title: Text(userMap!['name']),
//                     subtitle: Text(userMap!['email']),
//                     trailing: Icon(Icons.add),
//                   )
//                 : SizedBox(),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddMembersInGroup extends StatefulWidget {
  final String groupChatId, name;
  final List membersList;

  const AddMembersInGroup({
    required this.name,
    required this.membersList,
    required this.groupChatId,
    Key? key,
  }) : super(key: key);

  @override
  _AddMembersInGroupState createState() => _AddMembersInGroupState();
}

class _AddMembersInGroupState extends State<AddMembersInGroup> {
  final TextEditingController _search = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  List membersList = [];

  @override
  void initState() {
    super.initState();
    membersList = List.from(widget.membersList);
  }

  void onSearch() async {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (_search.text.trim().isEmpty) return;

    setState(() {
      isLoading = true;
      userMap = null;
    });

    try {
      final result = await _firestore
          .collection('users')
          .where("email", isEqualTo: _search.text.trim())
          .get();

      if (result.docs.isNotEmpty) {
        setState(() {
          userMap = result.docs.first.data();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found')),
        );
      }
    } catch (e) {
      print("Search error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  void onAddMembers() async {
    if (userMap == null) return;

    bool alreadyMember = membersList.any((element) => element['uid'] == userMap!['uid']);

    if (alreadyMember) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is already a member')),
      );
      return;
    }

    membersList.add(userMap);

    try {
      await _firestore.collection('groups').doc(widget.groupChatId).update({
        "members": membersList,
      });

      await _firestore
          .collection('users')
          .doc(userMap!['uid'])
          .collection('groups')
          .doc(widget.groupChatId)
          .set({"name": widget.name, "id": widget.groupChatId});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Member added successfully')),
      );

      setState(() {
        userMap = null;
        _search.clear();
      });
    } catch (e) {
      print("Add member error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add member')),
      );
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Members"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          child: Column(
            children: [
              TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: "Search by email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: onSearch,
                  ),
                ),
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : userMap != null
                  ? ListTile(
                onTap: onAddMembers,
                leading: Icon(Icons.account_box, color: Colors.blue),
                title: Text(userMap!['name']),
                subtitle: Text(userMap!['email']),
                trailing: Icon(Icons.add, color: Colors.green),
              )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
