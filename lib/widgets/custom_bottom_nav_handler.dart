import 'package:flutter/material.dart';

class CustomBottomNavHandler {
  static void onItemTapped(BuildContext context, int currentIndex, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/menu');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/ingredient');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/menu');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }
}
