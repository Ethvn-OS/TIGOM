import 'package:flutter/material.dart';
import 'package:tigom_app/pages/home.dart';
import 'package:tigom_app/pages/login.dart';
import 'package:tigom_app/pages/signup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tigom_app/pages/profile.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gynywphgyxdrlohhrphw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd5bnl3cGhneXhkcmxvaGhycGh3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc5MTUzMjYsImV4cCI6MjA5MzQ5MTMyNn0.GOlfpgvynoaes6yIj8up1iYmlXfmC9_8A6bZndtvq5Y',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        fontFamily: 'Amarante',
      ),

      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/signup': (context) => const SignUpPage(),
        '/profile': (context) => const EditProfilePage(),
      },
    );
  }
}