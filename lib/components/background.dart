import 'package:flutter/material.dart';
BoxDecoration gradientDecoration() {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Color(0xFF9A69AB), // Dark Purple
        Color(0xFFC4A5E8), // Lighter Shade of Purple
        Color(0xFFFF6F61), // Contrasting Color
      ],
    ),
  );
}