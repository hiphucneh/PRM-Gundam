import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton accessor for the Supabase client.
/// Usage anywhere in the app:
///   final client = SupabaseService.client;
class SupabaseService {
  SupabaseService._();

  /// The initialized Supabase client.
  static SupabaseClient get client => Supabase.instance.client;

  /// Currently signed-in user, or null if not authenticated.
  static User? get currentUser => client.auth.currentUser;
}
