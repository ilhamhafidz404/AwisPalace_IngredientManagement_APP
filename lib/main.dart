import 'package:flutter/material.dart';
import 'package:ingredient_management_app/features/home/presentation/pages/home_page.dart';
import 'package:ingredient_management_app/features/transaction/presentation/pages/transaction_page.dart';
import 'package:ingredient_management_app/pages/about_page.dart';
import 'pages/login_page.dart';
import 'features/menu/presentation/pages/menu_page.dart';
import 'features/ingredient/presentation/pages/ingredient_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/about': (context) => const AboutPage(),
        '/': (context) => const HomePage(),
        '/menu': (context) => const MenuPage(),
        '/transaction': (context) => const TransactionPage(),
        '/ingredient': (context) => const IngredientPage(),
      },
    );
  }
}
