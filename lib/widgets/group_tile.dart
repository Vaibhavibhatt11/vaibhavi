import 'package:flutter/material.dart';
import 'package:chatapp_final/pages/group_chat_page.dart';
import 'package:chatapp_final/pages/group_info.dart';

class GroupTile extends StatelessWidget {
  final String userName;
  final String groupId;
  final String groupName;
  final String adminName; // Add this if you want to pass admin info to GroupInfo

  const GroupTile({
    Key? key,
    required this.userName,
    required this.groupId,
    required this.groupName,
    required this.adminName,
  }) : super(key: key);

  void navigateToGroupChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupChatPage(
          groupId: groupId,
          groupName: groupName, userName: '',
        ),
      ),
    );
  }

  void navigateToGroupInfo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupInfo(
          groupId: groupId,
          groupName: groupName,
          adminName: adminName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            groupName.isNotEmpty ? groupName[0].toUpperCase() : "?",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          groupName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Join the conversation as $userName"),
        onTap: () => navigateToGroupChat(context),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'info') {
              navigateToGroupInfo(context);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'info',
              child: Text('Group Info'),
            ),
          ],
        ),
      ),
    );
  }
}
