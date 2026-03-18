import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserChatScreen extends StatefulWidget {
  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final client = Supabase.instance.client;
  final textController = TextEditingController();

  String get userId => client.auth.currentUser!.id;

  Future<void> send() async {
    if (textController.text.trim().isEmpty) return;

    await client.from('chat_message').insert({
      'user_id': userId,
      'message': textController.text.trim(),
      'is_from_admin': false,
    });

    textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat hỗ trợ"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: client
                  .from('chat_message')
                  .stream(primaryKey: ['id'])
                  .eq('user_id', userId)
                  .order('created_at'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final msg = messages[i];
                    final isMe = !msg['is_from_admin'];

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.orange : Colors.grey[300],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          msg['message'],
                          style: TextStyle(
                              color: isMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // INPUT
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: "Nhập tin nhắn...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.orange),
                  onPressed: send,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}