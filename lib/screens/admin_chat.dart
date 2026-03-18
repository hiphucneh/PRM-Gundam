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
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        final messages = snapshot.data ?? [];

        if (snapshot.connectionState == ConnectionState.waiting &&
            messages.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        final latestByUser = <String, Map<String, dynamic>>{};
        for (final message in messages) {
          final uid = message['user_id']?.toString();
          if (uid == null) continue;
          latestByUser.putIfAbsent(uid, () => Map<String, dynamic>.from(message));
        }

        final conversations = latestByUser.entries.toList();

        if (conversations.isEmpty) {
          return Center(
            child: Text(
              'Chưa có cuộc hội thoại nào',
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8),
          itemCount: conversations.length,
          itemBuilder: (_, i) {
            final uid = conversations[i].key;
            final latest = conversations[i].value;
            final lastMessage = (latest['message'] ?? '').toString();

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                leading: CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text("User ${i + 1}"),
                subtitle: Text(
                  lastMessage.isNotEmpty ? lastMessage : uid,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Icon(Icons.chat_bubble_outline, color: Colors.orange),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminChatDetail(userId: uid),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}