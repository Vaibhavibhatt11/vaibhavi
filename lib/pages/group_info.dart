import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String adminName;

  const GroupInfo({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.adminName,
  });

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> members = [];
  bool isAdmin = false;
  String searchEmail = '';
  Map<String, dynamic>? searchResult;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getMembers();
  }

  Future<void> getMembers() async {
    try {
      final snap = await _firestore.collection('groups').doc(widget.groupId).get();
      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>;
        final List<dynamic> memList = data['members'] ?? [];
        setState(() {
          members = List<String>.from(memList);
          isAdmin = (data['admin'] as String).split('_').first == _auth.currentUser!.uid;
          loading = false;
        });
      }
    } catch (e) {
      print('Error fetching members: $e');
    }
  }

  void searchUserByEmail() async {
    if (searchEmail.isEmpty) return;
    final result = await _firestore.collection('users').where('email', isEqualTo: searchEmail).get();
    if (result.docs.isNotEmpty) {
      setState(() {
        searchResult = result.docs.first.data() as Map<String, dynamic>;
        searchResult!['uid'] = result.docs.first.id;
      });
    } else {
      setState(() => searchResult = null);
    }
  }

  void addMember(String uid, String name) async {
    final memberId = "$uid\_$name";
    if (!members.contains(memberId)) {
      members.add(memberId);
      await _firestore.collection('groups').doc(widget.groupId).update({'members': members});
      await _firestore.collection('users').doc(uid).update({
        'groups': FieldValue.arrayUnion(["${widget.groupId}_${widget.groupName}"])
      });
      setState(() => searchResult = null);
    }
  }

  void removeMember(String memberId) async {
    members.remove(memberId);
    await _firestore.collection('groups').doc(widget.groupId).update({'members': members});
    final uid = memberId.contains('_') ? memberId.split('_').first : '';
    if (uid.isNotEmpty) {
      await _firestore.collection('users').doc(uid).update({
        'groups': FieldValue.arrayRemove(["${widget.groupId}_${widget.groupName}"])
      });
    }
    setState(() {});
  }

  void makeAdmin(String memberId) async {
    await _firestore.collection('groups').doc(widget.groupId).update({
      'admin': memberId,
    });
    setState(() {
      isAdmin = memberId.split('_')[0] == _auth.currentUser!.uid;
    });
  }

  void leaveGroup() async {
    final uid = _auth.currentUser!.uid;
    final match = members.firstWhere(
          (m) => m.startsWith(uid + '_'),
      orElse: () => '',
    );
    if (match.isNotEmpty) {
      members.remove(match);
      await _firestore.collection('groups').doc(widget.groupId).update({'members': members});
      await _firestore.collection('users').doc(uid).update({
        'groups': FieldValue.arrayRemove(["${widget.groupId}_${widget.groupName}"])
      });
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  Widget memberTile(String memberId) {
    final parts = memberId.split('_');
    if (parts.length < 2) return const SizedBox();

    final uid = parts[0];
    final name = parts[1];
    final isThisAdmin = widget.adminName == memberId;

    return ListTile(
      leading: CircleAvatar(child: Text(name.isNotEmpty ? name[0] : '?')),
      title: Text(name),
      subtitle: Text(isThisAdmin ? "Admin" : ""),
      trailing: isAdmin && !isThisAdmin
          ? PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'remove') removeMember(memberId);
          if (value == 'admin') makeAdmin(memberId);
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'remove', child: Text("Remove")),
          PopupMenuItem(value: 'admin', child: Text("Make Admin")),
        ],
      )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Info'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: leaveGroup,
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Container(
            color: Colors.blue.shade100,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.groupName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(widget.adminName.contains('_')
                    ? "Admin: ${widget.adminName.split('_')[1]}"
                    : "Admin")
              ],
            ),
          ),
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (val) => searchEmail = val,
                decoration: InputDecoration(
                  labelText: "Search user by email",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: searchUserByEmail,
                  ),
                ),
              ),
            ),
          if (searchResult != null)
            ListTile(
              title: Text(searchResult!['fullName'] ?? ''),
              subtitle: Text(searchResult!['email'] ?? ''),
              trailing: ElevatedButton(
                child: const Text("Add"),
                onPressed: () => addMember(
                    searchResult!['uid'], searchResult!['fullName']),
              ),
            ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text("Members", style: TextStyle(fontSize: 18)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (ctx, i) => memberTile(members[i]),
            ),
          ),
        ],
      ),
    );
  }
}