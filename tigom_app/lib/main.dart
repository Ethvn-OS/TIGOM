import 'package:flutter/material.dart';
import 'package:tigom_app/pages/home.dart';
import 'package:tigom_app/pages/login.dart';
import 'package:tigom_app/pages/signup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
<<<<<<< HEAD
        fontFamily: 'RuslanDisplay',
=======
        fontFamily: 'Amarante'
>>>>>>> main
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/signup': (context) => const SignUpPage(),
      },
    );
  }
}