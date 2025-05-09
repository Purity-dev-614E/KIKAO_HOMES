import 'package:flutter/material.dart';

class LandingTheme {
  // Main Colors from landing page
  static const Color primaryColor = Color(0xFF2A5C42);
  static const Color accentColor = Color(0xFFF6AE2D);
  static const Color textColor = Color(0xFF333333);
  
  // Button styles
  static ButtonStyle primaryButtonStyle({bool isHovered = false}) {
    return ElevatedButton.styleFrom(
      backgroundColor: isHovered ? accentColor : primaryColor,
      foregroundColor: Colors.white,
      elevation: isHovered ? 8 : 2,
      shadowColor: isHovered ? accentColor.withOpacity(0.4) : Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
  
  // Card styles
  static BoxDecoration cardDecoration({bool isHovered = false}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: isHovered 
              ? accentColor.withOpacity(0.2) 
              : Colors.black.withOpacity(0.1),
          blurRadius: isHovered ? 15 : 10,
          offset: Offset(0, isHovered ? 8 : 4),
          spreadRadius: isHovered ? 2 : 0,
        ),
      ],
      border: isHovered 
          ? Border.all(color: accentColor.withOpacity(0.3), width: 1.5)
          : null,
    );
  }
  
  // Text styles
  static TextStyle headingStyle({Color? color}) {
    return TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: color ?? Colors.white,
      letterSpacing: -0.5,
    );
  }
  
  static TextStyle subheadingStyle({Color? color}) {
    return TextStyle(
      fontSize: 18,
      color: color ?? Colors.white.withOpacity(0.9),
      fontWeight: FontWeight.w500,
    );
  }
  
  static TextStyle bodyStyle({Color? color}) {
    return TextStyle(
      fontSize: 16,
      color: color ?? Colors.white.withOpacity(0.9),
      height: 1.6,
    );
  }
  
  // Input decoration
  static InputDecoration inputDecoration(String label, {String? hint, Widget? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
      hintStyle: TextStyle(color: Colors.grey.shade500),
      errorStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
    );
  }
  
  // Container decoration for content sections
  static BoxDecoration contentContainerDecoration() {
    return BoxDecoration(
      color: Colors.black.withOpacity(0.2),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
        width: 1,
      ),
    );
  }
}