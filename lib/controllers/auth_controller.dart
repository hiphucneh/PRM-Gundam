import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {
  final _client = Supabase.instance.client;

  Future<int> getOrCreateCurrentUserRole() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User chưa đăng nhập');

    final existing = await _client
        .from('User')
        .select('role_id')
        .eq('user_id', user.id)
        .maybeSingle();

    if (existing != null) {
      return (existing['role_id'] as num?)?.toInt() ?? 2;
    }

    final fullName = (user.userMetadata?['full_name'] ??
            user.email?.split('@').first ??
            'User')
        .toString();

    await _client.from('User').insert({
      'user_id': user.id,
      'email': user.email,
      'full_name': fullName,
      'role_id': 2,
    });

    return 2;
  }

  /// 1. ĐĂNG NHẬP BẰNG GOOGLE (Cập nhật API v7+)
  Future<String?> signInWithGoogle() async {
    try {
      const webClientId = '132007106721-1a4aa0o9dk792jmlci23nmakp5rih371.apps.googleusercontent.com';
      const androidClientId = '132007106721-r1m3l9hm3622gjllkotb44plsv3r6lk9.apps.googleusercontent.com';

      final googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize(
        clientId: androidClientId,
        serverClientId: webClientId,
      );

      // Mở hộp thoại chọn tài khoản Google (nếu user hủy, sẽ nhảy thẳng xuống catch)
      final googleUser = await googleSignIn.authenticate();

      // Ở v7+, không cần await khi gọi authentication nữa
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) return 'Không tìm thấy ID Token từ Google.';

      // Gửi token sang Supabase
      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      await getOrCreateCurrentUserRole();

      return "SUCCESS";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      // Bắt luôn cả trường hợp người dùng bấm "Hủy" hoặc lỗi mạng
      return "Lỗi đăng nhập Google: $e";
    }
  }

  /// 2. ĐĂNG KÝ TÀI KHOẢN (Email & Password)
  Future<String?> signUp(String email, String password, String fullName) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      return "SUCCESS";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Lỗi hệ thống: $e";
    }
  }

  /// 3. ĐĂNG NHẬP (Email & Password)
  Future<String?> signIn(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      return "SUCCESS";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Lỗi hệ thống: $e";
    }
  }

  /// 4. ĐĂNG XUẤT
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// 5. LẤY THÔNG TIN USER HIỆN TẠI
  User? get currentUser => _client.auth.currentUser;
}