import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController {
  final _client = Supabase.instance.client;
  String? get _userId => _client.auth.currentUser?.id;

  /// Lấy thông tin Profile
  Future<Map<String, dynamic>?> getProfile() async {
    if (_userId == null) throw Exception("Vui lòng đăng nhập!");
    try {
      return await _client.from('User').select().eq('user_id', _userId!).maybeSingle();
    } catch (e) {
      throw Exception("Lỗi lấy thông tin cá nhân: $e");
    }
  }

  /// Cập nhật thông tin Profile
  Future<void> updateProfile({String? fullName, String? phone, String? address, String? avatarUrl}) async {
    if (_userId == null) throw Exception("Vui lòng đăng nhập!");
    try {
      final updates = {
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (avatarUrl != null) 'avatar_url': avatarUrl, // Note: DB doesn't have avatar_url yet, you might need to add it to DB later.
      };
      
      await _client.from('User').update(updates).eq('user_id', _userId!);
    } catch (e) {
      throw Exception("Lỗi cập nhật hồ sơ: $e");
    }
  }
}