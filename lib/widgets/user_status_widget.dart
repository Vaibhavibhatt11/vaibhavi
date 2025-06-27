import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserStatusWidget extends StatelessWidget {
  final String userId;

  const UserStatusWidget({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          String status = data['status'] ?? 'offline';
          return Row(
            children: [
              Icon(
                Icons.circle,
                color: status == 'online' ? Colors.green : Colors.grey,
                size: 10,
              ),
              SizedBox(width: 5),
              Text(status),
            ],
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
