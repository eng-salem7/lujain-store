import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // مفاتيح مشروع Supabase
  // يمكن استبدال هذه القيم بقيم مشروعك الجديد من لوحة تحكم Supabase: Project Settings -> API
  static const String supabaseUrl = 'https://your-project-id.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';

  static bool get isConfigured =>
      supabaseUrl.startsWith('https://') &&
      !supabaseUrl.contains('your-project-id') &&
      supabaseAnonKey.length > 20;

  static Future<void> initialize() async {
    if (isConfigured) {
      try {
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseAnonKey,
        );
      } catch (e) {
        // Fallback gracefully
      }
    }
  }

  static SupabaseClient? get client =>
      isConfigured ? Supabase.instance.client : null;
}
