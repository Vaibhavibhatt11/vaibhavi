import 'package:chatapp_final/helper/helper_function.dart';
import 'package:chatapp_final/pages/chat_page.dart';
import 'package:chatapp_final/service/database_service.dart';
import 'package:chatapp_final/widgets/widgets.dart' hide nextScreen;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String userName = "";
  User? user;
  Map<String, bool> joinedGroups = {}; // Track join status for each group

  @override
  void initState() {
    super.initState();
    getCurrentUserIdandName();
  }

  getCurrentUserIdandName() async {
    userName = await HelperFunctions.getUserNameFromSF() ?? '';
    user = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  String getName(String r) => r.substring(r.indexOf("_") + 1);
  String getId(String res) => res.substring(0, res.indexOf("_"));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Search",
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search groups....",
                      hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: initiateSearchMethod,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor))
              : Expanded(child: groupList()),
        ],
      ),
    );
  }

  initiateSearchMethod() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await DatabaseService().searchByName(searchController.text).then((snapshot) {
        searchSnapshot = snapshot;
        hasUserSearched = true;
        joinedGroups.clear();
        for (var doc in snapshot.docs) {
          final groupId = doc['groupId'];
          checkJoinedStatus(groupId, doc['groupName']);
        }
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  void checkJoinedStatus(String groupId, String groupName) async {
    final isUserJoined = await DatabaseService(uid: user!.uid).isUserJoined(groupName, groupId, userName);
    setState(() {
      joinedGroups[groupId] = isUserJoined;
    });
  }

  Widget groupList() {
    if (!hasUserSearched || searchSnapshot == null) return Container();
    return ListView.builder(
      itemCount: searchSnapshot!.docs.length,
      itemBuilder: (context, index) {
        final doc = searchSnapshot!.docs[index];
        return groupTile(
          userName,
          doc['groupId'],
          doc['groupName'],
          doc['admin'],
        );
      },
    );
  }

  Widget groupTile(String userName, String groupId, String groupName, String admin) {
    final bool isJoined = joinedGroups[groupId] ?? false;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(groupName.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white)),
      ),
      title: Text(groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text("Admin: ${getName(admin)}"),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(uid: user!.uid).toggleGroupJoin(groupId, userName, groupName);
          setState(() {
            joinedGroups[groupId] = !isJoined;
          });
          if (!isJoined) {
            showSnackbar(context, Colors.green, "Successfully joined the group");
            Future.delayed(const Duration(seconds: 1), () {
              nextScreen(
                context,
                ChatPage(groupId: groupId, groupName: groupName, userName: userName),
              );
            });
          } else {
            showSnackbar(context, Colors.red, "Left the group $groupName");
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isJoined ? Colors.black : Theme.of(context).primaryColor,
            border: Border.all(color: Colors.white),
          ),
          child: Text(isJoined ? "Joined" : "Join Now", style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
