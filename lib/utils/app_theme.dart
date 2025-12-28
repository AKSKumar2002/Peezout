import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Ultra Premium Color Palette
  static const Color obsidian = Color(0xFF050505);
  static const Color richBlack = Color(0xFF121212);
  static const Color deepCharcoal = Color(0xFF1E1E1E);
  
  static const Color vividGold = Color(0xFFFFD700);
  static const Color champagneGold = Color(0xFFF7E7CE);
  static const Color antiqueGold = Color(0xFFCFB53B);
  
  static const Color luxuryPurple = Color(0xFF7B2CBF);
  static const Color electricViolet = Color(0xFF9D4EDD);
  
  static const Color neonCyan = Color(0xFF00F0FF); // For gaming accents
  static const Color errorRed = Color(0xFFFF2D2D);
  static const Color successGreen = Color(0xFF00E676);

  static const Color glassWhite = Color(0x1AFFFFFF); // 10% opacity white
  static const Color glassBlack = Color(0x80000000); // 50% opacity black
  
  static const Color background = obsidian;
  static const Color surface = richBlack;

  // Aliases for compatibility
  static const Color midnightBlue = richBlack;
  static const Color deepBlack = obsidian;
  static const Color neonGreen = successGreen; // Mapped to successGreen or neonCyan depending on usage
  static const Color goldStart = vividGold;
  static const Color goldEnd = antiqueGold;
  static const Color primaryPurple = luxuryPurple;
  
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.5),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: vividGold.withOpacity(0.2),
      blurRadius: 20,
      offset: const Offset(0, 0),
      spreadRadius: 2,
    ),
  ];
  
  static List<BoxShadow> get purpleGlow => [
    BoxShadow(
      color: luxuryPurple.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 0),
      spreadRadius: 2,
    ),
  ];

  // Premium Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [vividGold, antiqueGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient premiumDarkGradient = LinearGradient(
    colors: [obsidian, deepCharcoal],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient violetGradient = LinearGradient(
    colors: [luxuryPurple, electricViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x26FFFFFF), Color(0x05FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark Theme Configuration
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: vividGold,
      scaffoldBackgroundColor: obsidian,
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: vividGold,
        onPrimary: Colors.black,
        secondary: luxuryPurple,
        onSecondary: Colors.white,
        surface: surface,
        onSurface: Colors.white,
        background: obsidian,
        onBackground: Colors.white,
        error: errorRed,
      ),
      fontFamily: GoogleFonts.outfit().fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32),
        displayMedium: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        displaySmall: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),
        headlineLarge: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.outfit(color: champagneGold, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        titleMedium: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16),
        bodyMedium: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 14),
        labelLarge: GoogleFonts.outfit(color: vividGold, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
        color: surface,
      ),
      iconTheme: const IconThemeData(color: champagneGold),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: vividGold,
          foregroundColor: Colors.black,
          elevation: 10,
          shadowColor: vividGold.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: vividGold,
          side: const BorderSide(color: vividGold, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: deepCharcoal,
        labelStyle: GoogleFonts.plusJakartaSans(color: Colors.white60),
        floatingLabelStyle: GoogleFonts.outfit(color: vividGold),
        prefixIconColor: champagneGold,
        suffixIconColor: champagneGold,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: vividGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: richBlack.withOpacity(0.9),
        selectedItemColor: vividGold,
        unselectedItemColor: Colors.white38,
        selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
