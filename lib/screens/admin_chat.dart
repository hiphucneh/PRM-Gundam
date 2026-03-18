import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_chat_detail.dart';

class AdminChatScreen extends StatelessWidget {
  final client = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: client
          .from('chat_message')
          .stream(primaryKey: ['id'])
          .order('created_at'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!;

        // 🔥 lấy danh sách user_id unique
        final userIds = messages
            .map((e) => e['user_id'])
            .toSet()
            .toList();

        return ListView.builder(
          itemCount: userIds.length,
          itemBuilder: (_, i) {
            final uid = userIds[i];

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text("User $i"),
              subtitle: Text(uid),
              trailing: Icon(Icons.chat, color: Colors.orange),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminChatDetail(userId: uid),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}