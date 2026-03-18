import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final _client = Supabase.instance.client;

  Future<String> uploadImage(File file) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();

    await _client.storage
        .from('product-images')
        .upload(fileName, file);

    final url = _client.storage
        .from('product-images')
        .getPublicUrl(fileName);

    return url;
  }
}