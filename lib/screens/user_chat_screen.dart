import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserChatScreen extends StatefulWidget {
  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final client = Supabase.instance.client;
  final textController = TextEditingController();
  final scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;
  Timer? pollTimer;

  String get userId => client.auth.currentUser!.id;

  @override
  void initState() {
    super.initState();
    fetchMessages();
    pollTimer = Timer.periodic(Duration(seconds: 1), (_) => fetchMessages());
  }

  Future<void> fetchMessages() async {
    try {
      final data = await client
          .from('chat_message')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      if (!mounted) return;

      setState(() {
        messages = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scrollController.hasClients) return;
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> send() async {
    if (textController.text.trim().isEmpty) return;

    await client.from('chat_message').insert({
      'user_id': userId,
      'message': textController.text.trim(),
      'is_from_admin': false,
    });

    textController.clear();
    await fetchMessages();
  }

  @override
  void dispose() {
    pollTimer?.cancel();
    textController.dispose();
    scrollController.dispose();
    super.dispose();
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
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: scrollController,
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
                    onSubmitted: (_) => send(),
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