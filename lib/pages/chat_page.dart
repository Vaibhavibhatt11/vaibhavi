import 'package:chatapp_final/helper/helper_function.dart';
import 'package:chatapp_final/pages/group_info.dart';
import 'package:chatapp_final/service/database_service.dart';
import 'package:chatapp_final/widgets/message_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;

  const ChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.userName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  final TextEditingController messageController = TextEditingController();
  String admin = "";

  @override
  void initState() {
    super.initState();
    getChatAndAdmin();
  }

  void getChatAndAdmin() {
    DatabaseService().getChats(widget.groupId).then((val) {
      setState(() => chats = val);
    });

    DatabaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() => admin = val);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              nextScreen(
                context,
                  GroupInfo(
                  groupId: widget.groupId,
                  groupName: widget.groupName,
                  adminName: admin,
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          chatMessages(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              color: Colors.grey[700],
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Send a message...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget chatMessages() {
    return StreamBuilder<QuerySnapshot>(
      stream: chats,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80, top: 10),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final chat = snapshot.data!.docs[index];
            return MessageTile(
              message: chat['message'],
              sender: chat['sender'],
              sentByMe: widget.userName == chat['sender'],
            );
          },
        );
      },
    );
  }

  void sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    final chatMessageMap = {
      "message": messageController.text.trim(),
      "sender": widget.userName,
      "time": DateTime.now().millisecondsSinceEpoch,
    };

    DatabaseService().sendMessage(widget.groupId, chatMessageMap);
    messageController.clear();
  }
}
