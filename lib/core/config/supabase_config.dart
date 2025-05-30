import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static final String supabaseUrl = dotenv.env['SUPABASE_URL']!;
  static final String supabaseAnonKey = dotenv.env['SUPABASE_KEY_ANON']!;
}
