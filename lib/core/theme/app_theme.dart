import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.brown,
      useMaterial3: true,
      scaffoldBackgroundColor: javaneseBeige,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: javaneseBrown,
        foregroundColor: javaneseGold,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: javaneseGold,
          letterSpacing: 1.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      ),
    );
  }

  // Javanese Classical Color Palette - Mewah & Elegan
  static const Color javaneseBrown = Color(
    0xFF3E2723,
  ); // Coklat tua seperti kayu jati
  static const Color javaneseBrownLight = Color(0xFF4E342E); // Coklat medium
  static const Color javaneseGold = Color(0xFFD4AF37); // Emas klasik
  static const Color javaneseGoldLight = Color(0xFFFFD700); // Emas terang
  static const Color javaneseBeige = Color(0xFFF5F5DC); // Krem/beige
  static const Color javaneseMaroon = Color(0xFF800000); // Merah marun
  static const Color javaneseGreen = Color(0xFF556B2F); // Hijau lumut
  static const Color javanesesCream = Color(0xFFFFF8DC); // Cream

  // Legacy colors (kept for backward compatibility)
  static const Color primaryColor = javaneseBrown;
  static const Color primaryDark = javaneseBrownLight;
  static const Color cardBackground = javaneseBeige;
  static const Color accentPurple = javaneseMaroon;

  // Gradient untuk efek mewah
  static const LinearGradient javaneseGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4AF37), Color(0xFFFFD700), Color(0xFFC5A028)],
  );

  static const LinearGradient javaneseBrownGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3E2723), Color(0xFF4E342E), Color(0xFF5D4037)],
  );

  // Shadow untuk depth (kesan 3D)
  static List<BoxShadow> get elegantShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 15,
      offset: const Offset(0, 8),
      spreadRadius: 2,
    ),
    BoxShadow(
      color: javaneseGold.withValues(alpha: .1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // Border ornamental style
  static BoxDecoration get ornamentalBorder => BoxDecoration(
    border: Border.all(color: javaneseGold, width: 2),
    boxShadow: elegantShadow,
  );
}
