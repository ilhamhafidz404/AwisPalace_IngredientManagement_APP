import 'package:flutter/material.dart';

class BadgeWidget extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const BadgeWidget({
    super.key,
    required this.label,
    this.backgroundColor = const Color(0xFFEBD4FF),
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: textColor)),
    );
  }
}
