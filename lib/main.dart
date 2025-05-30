import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './features/auth/presentation/pages/login.dart';
import 'core/config/supabase_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('Environment variables loaded successfully.');
  } catch (e) {
    debugPrint('Error loading .env file: $e');
    // Depending on your app's requirements, you might want to
    // show an error, exit, or use default values here.
    // For now, we'll just print.
  }
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl, // 🔁 Reemplaza con tu URL
    anonKey: SupabaseConfig.supabaseAnonKey, // 🔁 Reemplaza con tu anon key
  );

  runApp(MyApp());
}

// 🔧 Aquí defines la clase MyApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vivero La Vega',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),

      // 📌 Usa `routes.dart` para manejar rutas
      initialRoute: '/login',
      routes: routes,

      home: const LoginPage(), // Pantalla de login
    );
  }
}
