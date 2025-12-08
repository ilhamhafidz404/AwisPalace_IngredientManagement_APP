import 'package:flutter/material.dart';
import 'package:ingredient_management_app/features/home/presentation/pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/menu_page.dart';
import 'pages/hitung_page.dart';
import 'pages/kelola_bahan.dart';
import 'pages/profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/login': (context) => const LoginPage(),
        '/': (context) => const HomePage(),
        '/menu': (context) => const MenuPage(),
        '/hitung': (context) => const HitungPage(),
        '/kelola': (context) => const KelolaBahanPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
