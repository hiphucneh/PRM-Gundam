import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatController extends GetxController {
  final _client = Supabase.instance.client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw Exception('User not authenticated');
    return id;
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      await _client.from('chat_message').insert({
        'user_id': _userId,
        'message': text,
        'is_from_admin': false,
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> streamMessages() {
    try {
      return _client
          .from('chat_message')
          .stream(primaryKey: ['id'])
          .eq('user_id', _userId)
          .order('created_at', ascending: true);
    } catch (e) {
      Get.snackbar('Error', 'Failed to connect to chat stream');
      throw Exception('Failed to stream messages: $e');
    }
  }
}