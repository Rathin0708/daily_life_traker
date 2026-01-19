import 'package:flutter/material.dart';

class SoloLevelingColors {
  // Core Dark Theme - Absolute Black Foundation
  static const Color absoluteBlack = Color(0xFF0B0B0F);
  static const Color deepCharcoal = Color(0xFF14141A);
  static const Color slateGray = Color(0xFF1E2029);
  
  // Accent Colors - Context Based
  static const Color electricBlue = Color(0xFF00BFFF); // Normal Mode
  static const Color indigoGlow = Color(0xFF4B0082);   // Power States
  static const Color purpleEnergy = Color(0xFF8A2BE2); // Level Up / Power Gain
  static const Color crimsonRed = Color(0xFFDC143C);   // Penalty Zone
  static const Color amberGold = Color(0xFFFFD700);    // Boss Quest
  static const Color neonCyan = Color(0xFF00FFFF);     // System Messages
  
  // UI Elements
  static const Color cardSurface = Color(0xFF1A1C25);
  static const Color panelBorder = Color(0xFF2D3142);
  static const Color textPrimary = Color(0xFFE6E6FA);
  static const Color textSecondary = Color(0xFFA0A0C0);
  static const Color textDisabled = Color(0xFF666680);
  
  // Status Colors
  static const Color successGlow = Color(0xFF00FF7F);
  static const Color warningPulse = Color(0xFFFFA500);
  static const Color dangerFlash = Color(0xFFFF4500);
  
  // Particle Effects
  static const Color particleCore = Color(0xFF7B68EE);
  static const Color particleTrail = Color(0xFFBA55D3);
}

class SoloLevelingGradients {
  // Background Gradients
  static const LinearGradient systemInit = LinearGradient(
    colors: [SoloLevelingColors.absoluteBlack, SoloLevelingColors.deepCharcoal],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient powerField = LinearGradient(
    colors: [SoloLevelingColors.electricBlue, SoloLevelingColors.indigoGlow],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static const LinearGradient penaltyVeil = LinearGradient(
    colors: [SoloLevelingColors.crimsonRed, SoloLevelingColors.deepCharcoal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient bossAura = LinearGradient(
    colors: [SoloLevelingColors.amberGold, SoloLevelingColors.purpleEnergy],
    begin: Alignment.center,
    end: Alignment.center,
  );
  
  // Button Gradients
  static const LinearGradient acceptQuest = LinearGradient(
    colors: [SoloLevelingColors.electricBlue, SoloLevelingColors.neonCyan],
  );
  
  static const LinearGradient completeTask = LinearGradient(
    colors: [SoloLevelingColors.successGlow, SoloLevelingColors.electricBlue],
  );
  
  static const LinearGradient dangerZone = LinearGradient(
    colors: [SoloLevelingColors.crimsonRed, SoloLevelingColors.dangerFlash],
  );
}

class SoloLevelingShadows {
  static List<BoxShadow> cardGlow(Color color, {double blur = 15, double spread = 2}) {
    return [
      BoxShadow(
        color: color.withOpacity(0.4),
        blurRadius: blur,
        spreadRadius: spread,
      ),
      BoxShadow(
        color: color.withOpacity(0.2),
        blurRadius: blur * 1.5,
        spreadRadius: spread * 0.5,
      ),
    ];
  }
  
  static List<BoxShadow> textGlow(Color color, {double blur = 8}) {
    return [
      BoxShadow(
        color: color.withOpacity(0.8),
        blurRadius: blur,
        offset: const Offset(0, 0),
      ),
    ];
  }
  
  static List<BoxShadow> auraEffect(Color color, {double intensity = 1.0}) {
    return [
      BoxShadow(
        color: color.withOpacity(0.3 * intensity),
        blurRadius: 20 * intensity,
        spreadRadius: 5 * intensity,
      ),
      BoxShadow(
        color: color.withOpacity(0.1 * intensity),
        blurRadius: 40 * intensity,
        spreadRadius: 10 * intensity,
      ),
    ];
  }
}

class SoloLevelingTypography {
  static const TextStyle systemTitle = TextStyle(
    fontFamily: 'Orbitron', // Futuristic font for system text
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: SoloLevelingColors.textPrimary,
    letterSpacing: 1.2,
    shadows: [
      Shadow(
        color: SoloLevelingColors.electricBlue,
        blurRadius: 10,
        offset: Offset(0, 0),
      ),
    ],
  );
  
  static const TextStyle questTitle = TextStyle(
    fontFamily: 'Exo2', // Clean, modern font
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: SoloLevelingColors.textPrimary,
    letterSpacing: 0.5,
  );
  
  static const TextStyle systemText = TextStyle(
    fontFamily: 'ShareTechMono', // Monospace for system messages
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: SoloLevelingColors.neonCyan,
    letterSpacing: 1.0,
  );
  
  static const TextStyle statNumber = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: SoloLevelingColors.textPrimary,
    letterSpacing: 1.5,
  );
  
  static const TextStyle rankDisplay = TextStyle(
    fontFamily: 'Exo2',
    fontSize: 48,
    fontWeight: FontWeight.w900,
    color: SoloLevelingColors.amberGold,
    letterSpacing: 2.0,
    shadows: [
      Shadow(
        color: SoloLevelingColors.amberGold,
        blurRadius: 15,
        offset: Offset(0, 0),
      ),
    ],
  );
}

class SoloLevelingTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SoloLevelingColors.absoluteBlack,
      
      colorScheme: ColorScheme.dark(
        primary: SoloLevelingColors.electricBlue,
        secondary: SoloLevelingColors.purpleEnergy,
        surface: SoloLevelingColors.cardSurface,
        error: SoloLevelingColors.crimsonRed,
        onPrimary: SoloLevelingColors.textPrimary,
        onSecondary: SoloLevelingColors.textPrimary,
        onSurface: SoloLevelingColors.textPrimary,
        onError: SoloLevelingColors.textPrimary,
      ),
      
      // Card Theme - Quest Panels
      cardTheme:  CardThemeData(
        color: SoloLevelingColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: SoloLevelingColors.panelBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      
      // Elevated Button - System Actions
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SoloLevelingColors.electricBlue,
          foregroundColor: SoloLevelingColors.textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: SoloLevelingTypography.systemText.copyWith(
            fontSize: 14,
            color: SoloLevelingColors.textPrimary,
          ),
        ),
      ),
      
      // Text Theme
      textTheme: TextTheme(
        headlineLarge: SoloLevelingTypography.systemTitle,
        headlineMedium: SoloLevelingTypography.questTitle,
        bodyLarge: SoloLevelingTypography.systemText,
        bodyMedium: SoloLevelingTypography.systemText.copyWith(
          color: SoloLevelingColors.textSecondary,
          fontSize: 14,
        ),
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: SoloLevelingColors.absoluteBlack,
        elevation: 0,
        titleTextStyle: SoloLevelingTypography.systemTitle.copyWith(
          fontSize: 20,
        ),
        iconTheme: IconThemeData(
          color: SoloLevelingColors.textPrimary,
        ),
      ),
      
      // Bottom Navigation Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: SoloLevelingColors.deepCharcoal,
        selectedItemColor: SoloLevelingColors.electricBlue,
        unselectedItemColor: SoloLevelingColors.textSecondary,
        selectedIconTheme: IconThemeData(
          color: SoloLevelingColors.electricBlue,
        ),
        unselectedIconTheme: IconThemeData(
          color: SoloLevelingColors.textSecondary,
        ),
      ),
    );
  }
}