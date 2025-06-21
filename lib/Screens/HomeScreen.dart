// import 'package:chat_app/Authenticate/Methods.dart';
// import 'package:chat_app/Screens/ChatRoom.dart';
// import 'package:chat_app/group_chats/group_chat_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
//   Map<String, dynamic>? userMap;
//   bool isLoading = false;
//   final TextEditingController _search = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     setStatus("Online");
//   }
//
//   void setStatus(String status) async {
//     await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
//       "status": status,
//     });
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       // online
//       setStatus("Online");
//     } else {
//       // offline
//       setStatus("Offline");
//     }
//   }
//
//   String chatRoomId(String user1, String user2) {
//     if (user1[0].toLowerCase().codeUnits[0] >
//         user2.toLowerCase().codeUnits[0]) {
//       return "$user1$user2";
//     } else {
//       return "$user2$user1";
//     }
//   }
//
//   void onSearch() async {
//     FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
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
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Home Screen"),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () => logOut(context),
//           ),
//         ],
//       ),
//       body: isLoading
//           ? Center(
//               child: Container(
//                 height: size.height / 20,
//                 width: size.height / 20,
//                 child: CircularProgressIndicator(),
//               ),
//             )
//           : Column(
//               children: [
//                 SizedBox(height: size.height / 20),
//                 Container(
//                   height: size.height / 14,
//                   width: size.width,
//                   alignment: Alignment.center,
//                   child: Container(
//                     height: size.height / 14,
//                     width: size.width / 1.15,
//                     child: TextField(
//                       controller: _search,
//                       decoration: InputDecoration(
//                         hintText: "Search",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: size.height / 50),
//                 ElevatedButton(onPressed: onSearch, child: Text("Search")),
//                 SizedBox(height: size.height / 30),
//                 userMap != null
//                     ? ListTile(
//                         onTap: () {
//                           String roomId = chatRoomId(
//                             _auth.currentUser!.displayName!,
//                             userMap!['name'],
//                           );
//
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (_) => ChatRoom(
//                                 chatRoomId: roomId,
//                                 userMap: userMap!,
//                               ),
//                             ),
//                           );
//                         },
//                         leading: Icon(Icons.account_box, color: Colors.black),
//                         title: Text(
//                           userMap!['name'],
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 17,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         subtitle: Text(userMap!['email']),
//                         trailing: Icon(Icons.chat, color: Colors.black),
//                       )
//                     : Container(),
//               ],
//             ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.group),
//         onPressed: () => Navigator.of(
//           context,
//         ).push(MaterialPageRoute(builder: (_) => GroupChatHomeScreen())),
//       ),
//     );
//   }
// }

//
// import 'package:chat_app/Authenticate/Methods.dart';
// import 'package:chat_app/Screens/ChatRoom.dart';
// import 'package:chat_app/group_chats/group_chat_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
//   Map<String, dynamic>? userMap;
//   bool isLoading = false;
//
//   final TextEditingController _search = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     setStatus("Online");
//   }
//
//   void setStatus(String status) async {
//     if (_auth.currentUser != null) {
//       await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
//         "status": status,
//       });
//     }
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       setStatus("Online");
//     } else {
//       setStatus("Offline");
//     }
//   }
//
//   String chatRoomId(String user1, String user2) {
//     return user1.compareTo(user2) > 0 ? "$user1$user2" : "$user2$user1";
//   }
//
//   void onSearch() async {
//     if (_search.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Please enter an email to search."),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }
//
//     setState(() {
//       isLoading = true;
//       userMap = null;
//     });
//
//     try {
//       final result = await _firestore
//           .collection('users')
//           .where("email", isEqualTo: _search.text.trim())
//           .get();
//
//       if (result.docs.isNotEmpty) {
//         setState(() {
//           userMap = result.docs.first.data();
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("No user found with this email."),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       print("Search error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error occurred: ${e.toString()}"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Home Screen"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () => logOut(context),
//           ),
//         ],
//       ),
//       body: isLoading
//           ? Center(
//         child: SizedBox(
//           height: size.height / 20,
//           width: size.height / 20,
//           child: const CircularProgressIndicator(),
//         ),
//       )
//           : Column(
//         children: [
//           SizedBox(height: size.height / 20),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: TextField(
//               controller: _search,
//               decoration: InputDecoration(
//                 hintText: "Search by email",
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           ElevatedButton(
//             onPressed: onSearch,
//             child: const Text("Search"),
//           ),
//           const SizedBox(height: 20),
//           userMap != null
//               ? ListTile(
//             onTap: () {
//               String roomId = chatRoomId(
//                 _auth.currentUser!.displayName ?? "Me",
//                 userMap!['name'],
//               );
//
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (_) => ChatRoom(
//                     chatRoomId: roomId,
//                     userMap: userMap!,
//                   ),
//                 ),
//               );
//             },
//             leading: const Icon(Icons.account_box,
//                 color: Colors.black),
//             title: Text(
//               userMap!['name'],
//               style: const TextStyle(
//                 color: Colors.black,
//                 fontSize: 17,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             subtitle: Text(userMap!['email']),
//             trailing: const Icon(Icons.chat, color: Colors.black),
//           )
//               : const SizedBox.shrink(),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: const Icon(Icons.group),
//         onPressed: () {
//           Navigator.of(context).push(
//             MaterialPageRoute(builder: (_) => const GroupChatHomeScreen()),
//           );
//         },
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _search.dispose();
//     super.dispose();
//   }
// }


import 'package:chat_app/Authenticate/Methods.dart';
import 'package:chat_app/Screens/ChatRoom.dart';
import 'package:chat_app/group_chats/group_chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus("Online");
  }

  void setStatus(String status) async {
    if (_auth.currentUser != null) {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        "status": status,
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setStatus(state == AppLifecycleState.resumed ? "Online" : "Offline");
  }

  String chatRoomId(String u1, String u2) => u1.compareTo(u2) > 0 ? "$u1$u2" : "$u2$u1";

  void onSearch() async {
    final email = _search.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an email to search."), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() {
      isLoading = true;
      userMap = null;
    });
    try {
      final result = await _firestore.collection('users').where("email", isEqualTo: email).get();
      if (result.docs.isNotEmpty) {
        userMap = result.docs.first.data();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No user found with this email."), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error occurred: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentUser = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => logOut(context))],
      ),
      body: isLoading
          ? Center(child: SizedBox(height: size.height / 20, width: size.height / 20, child: const CircularProgressIndicator()))
          : Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: "Search by email",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: onSearch, child: const Text("Search")),
            ]),
          ),
          const SizedBox(height: 16),
          userMap != null
              ? ListTile(
            onTap: () {
              final roomId = chatRoomId(currentUser!.displayName!, userMap!['name']);
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatRoom(chatRoomId: roomId, userMap: userMap!)));
            },
            leading: const Icon(Icons.account_box),
            title: Text(userMap!['name']),
            subtitle: Text(userMap!['email']),
            trailing: const Icon(Icons.chat),
          )
              : const SizedBox.shrink(),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chatroom')
                  .doc(currentUser!.displayName)
                  .collection('rooms')
                  .orderBy('lastTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No recent chats"));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, idx) {
                    final doc = snapshot.data!.docs[idx];
                    return ListTile(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ChatRoom(
                            chatRoomId: doc.id,
                            userMap: {
                              'name': doc['peerName'],
                              'uid': doc['peerUid'],
                            },
                          ),
                        ));
                      },
                      leading: const Icon(Icons.chat_bubble_outline),
                      title: Text(doc['peerName']),
                      subtitle: Text(doc['lastMsg']),
                      trailing: Text(
                        TimeOfDay.fromDateTime(doc['lastTime'].toDate()).format(context),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.group),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GroupChatHomeScreen())),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _search.dispose();
    super.dispose();
  }
}
