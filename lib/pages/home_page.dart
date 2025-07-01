// File: home_page.dart
import 'package:chatapp_final/helper/helper_function.dart';
import 'package:chatapp_final/pages/auth/login_page.dart';
import 'package:chatapp_final/pages/profile_page.dart';
import 'package:chatapp_final/pages/search_page.dart';
import 'package:chatapp_final/pages/personal_chat_menu.dart';
import 'package:chatapp_final/service/auth_service.dart';
import 'package:chatapp_final/service/database_service.dart';
import 'package:chatapp_final/service/user_status_service.dart';
import 'package:chatapp_final/widgets/group_tile.dart';
import 'package:chatapp_final/widgets/widgets.dart' hide nextScreen;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'auth/edit_profile_page.dart';
import 'group_chat_page.dart';
import 'group_info.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "";
  String email = "";
  String profileImage = "";
  AuthService authService = AuthService();
  Stream? groups;
  bool _isLoading = false;
  String groupName = "";
  UserStatusService? _statusService;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _statusService = UserStatusService(user.uid);
      gettingUserData(user.uid);
    }
  }

  @override
  void dispose() {
    _statusService?.dispose();
    super.dispose();
  }

  String getId(String res) => res.substring(0, res.indexOf("_"));
  String getName(String res) => res.substring(res.indexOf("_") + 1);

  Future<void> gettingUserData(String uid) async {
    email = await HelperFunctions.getUserEmailFromSF() ?? "";
    userName = await HelperFunctions.getUserNameFromSF() ?? "";
    groups = await DatabaseService(uid: uid).getUserGroups();
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (snapshot.exists) {
      profileImage = snapshot.data()?['profileImage'] ?? '';
    }
    setState(() {});
  }

  Future<void> _editProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(userName: userName, email: email),
      ),
    );
    if (result == true) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) gettingUserData(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => nextScreen(context, const SearchPage()),
            icon: const Icon(Icons.search),
          ),
        ],
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Groups",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 27),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            profileImage.isNotEmpty
                ? CircleAvatar(radius: 70, backgroundImage: NetworkImage(profileImage))
                : const CircleAvatar(radius: 70, child: Icon(Icons.account_circle, size: 70)),
            const SizedBox(height: 15),
            Text(userName, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            const Divider(height: 2),
            ListTile(
              onTap: () {},
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text("Groups", style: TextStyle(color: Colors.black)),
            ),
            ListTile(
              onTap: _editProfile,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.edit),
              title: const Text("Edit Profile", style: TextStyle(color: Colors.black)),
            ),
            ListTile(
              title: const Text("Personal Chat"),
              leading: const Icon(Icons.person),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PersonalChatMenuPage()),
                );
              },
            ),
            ListTile(
              onTap: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                    'status': 'offline',
                    'lastSeen': FieldValue.serverTimestamp(),
                  });
                  await authService.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false,
                  );
                }
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Logout", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => popUpDialog(context),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  popUpDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: ((context, setState) {
            return AlertDialog(
              title: const Text("Create a group", textAlign: TextAlign.left),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isLoading
                      ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor))
                      : TextField(
                    onChanged: (val) => setState(() => groupName = val),
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                  child: const Text("CANCEL"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (groupName.isNotEmpty) {
                      setState(() => _isLoading = true);
                      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                          .createGroup(userName, FirebaseAuth.instance.currentUser!.uid, groupName);
                      setState(() => _isLoading = false);
                      Navigator.of(context).pop();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showSnackbar(context, Colors.green, "Group created successfully.");
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                  child: const Text("CREATE"),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  Widget groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data['groups'] != null &&
            (snapshot.data['groups'] as List).isNotEmpty) {
          return ListView.builder(
            itemCount: snapshot.data['groups'].length,
            itemBuilder: (context, index) {
              int reverseIndex = snapshot.data['groups'].length - index - 1;
              String groupId = getId(snapshot.data['groups'][reverseIndex]);
              String groupName = getName(snapshot.data['groups'][reverseIndex]);

              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupChatPage(
                      groupId: groupId,
                      groupName: groupName,
                      userName: userName,
                    ),
                  ),
                ),
                onLongPress: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupInfo(
                      groupId: groupId,
                      groupName: groupName,
                      adminName: snapshot.data['uid'] + '_' + snapshot.data['fullName'],
                    ),
                  ),
                ),
                child: GroupTile(
                  groupId: groupId,
                  groupName: groupName,
                  userName: snapshot.data['fullName'],
                  adminName: '',
                ),
              );
            },
          );
        } else {
          return noGroupWidget();
        }
      },
    );
  }

  Widget noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => popUpDialog(context),
            child: Icon(Icons.add_circle, color: Colors.grey[700], size: 75),
          ),
          const SizedBox(height: 20),
          const Text(
            "You've not joined any groups, tap on the add icon to create a group or also search from top search button.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
