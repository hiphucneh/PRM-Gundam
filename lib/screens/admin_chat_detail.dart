import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminChatDetail extends StatefulWidget {
  final String userId;

  const AdminChatDetail({required this.userId});

  @override
  State<AdminChatDetail> createState() => _AdminChatDetailState();
}

class _AdminChatDetailState extends State<AdminChatDetail> {
  final client = Supabase.instance.client;
  final textController = TextEditingController();

  Future<void> send() async {
    if (textController.text.trim().isEmpty) return;

    await client.from('chat_message').insert({
      'user_id': widget.userId,
      'message': textController.text.trim(),
      'is_from_admin': true,
    });

    textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat với user"),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: client
                  .from('chat_message')
                  .stream(primaryKey: ['id'])
                  .eq('user_id', widget.userId)
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
                    final isAdmin = msg['is_from_admin'];

                    return Align(
                      alignment: isAdmin
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isAdmin
                              ? Colors.orange
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          msg['message'],
                          style: TextStyle(
                              color:
                                  isAdmin ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Row(
            children: [
              Expanded(
                child: TextField(controller: textController),
              ),
              IconButton(
                icon: Icon(Icons.send, color: Colors.orange),
                onPressed: send,
              )
            ],
          )
        ],
      ),
    );
  }
}