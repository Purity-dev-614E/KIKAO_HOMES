import 'package:flutter/material.dart';
import 'landing_theme.dart';

class DashboardTheme {
  // Main Colors - using the same as landing theme for consistency
  static const Color primaryColor = LandingTheme.primaryColor;
  static const Color accentColor = LandingTheme.accentColor;
  static const Color backgroundColor = Color(0xFFF8F7F5);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF333333);
  static const Color secondaryTextColor = Color(0xFF666666);
  
  // Dashboard specific colors
  static const Color sidebarColor = Color(0xFF2A5C42); // Same as primary
  static const Color sidebarActiveColor = Color(0xFFF6AE2D); // Same as accent
  static const Color sidebarHoverColor = Color(0xFF3A6C52); // Slightly lighter than primary
  static const Color dividerColor = Color(0xFFEEEEEE);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFA726);
  static const Color errorColor = Color(0xFFE53935);
  static const Color infoColor = Color(0xFF2196F3);
  
  // Text styles
  static TextStyle get headingStyle => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColor,
  );
  
  static TextStyle get subheadingStyle => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textColor,
  );
  
  static TextStyle get bodyStyle => const TextStyle(
    fontSize: 14,
    color: textColor,
  );
  
  static TextStyle get smallTextStyle => TextStyle(
    fontSize: 12,
    color: textColor.withOpacity(0.7),
  );
  
  // Card styles
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  static BoxDecoration cardDecorationWithHover({bool isHovered = false}) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(12),
      border: isHovered 
          ? Border.all(color: accentColor.withOpacity(0.5), width: 1.5)
          : Border.all(color: Colors.grey.shade200, width: 1),
      boxShadow: [
        BoxShadow(
          color: isHovered 
              ? accentColor.withOpacity(0.1) 
              : Colors.black.withOpacity(0.05),
          blurRadius: isHovered ? 15 : 10,
          offset: Offset(0, isHovered ? 8 : 4),
          spreadRadius: isHovered ? 1 : 0,
        ),
      ],
    );
  }
  
  // Button styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
  
  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: primaryColor,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    side: const BorderSide(color: primaryColor),
  );
  
  static ButtonStyle get accentButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: accentColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
  
  // Input decoration
  static InputDecoration inputDecoration(String label, {String? hint, Widget? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade700),
      hintStyle: TextStyle(color: Colors.grey.shade400),
    );
  }
  
  // Table styles
  static TableBorder get tableBorder => TableBorder(
    horizontalInside: BorderSide(
      color: Colors.grey.shade200,
      width: 1,
    ),
    bottom: BorderSide(
      color: Colors.grey.shade200,
      width: 1,
    ),
  );
  
  static BoxDecoration get tableHeaderDecoration => BoxDecoration(
    color: Colors.grey.shade100,
    border: Border(
      bottom: BorderSide(
        color: Colors.grey.shade300,
        width: 1,
      ),
    ),
  );
  
  // Dashboard card styles
  static BoxDecoration dashboardCardDecoration({Color? accentColorOverride}) {
    final Color cardAccent = accentColorOverride ?? accentColor;
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border(
        top: BorderSide(
          color: cardAccent,
          width: 4,
        ),
      ),
    );
  }
  
  // Status indicator styles
  static BoxDecoration statusIndicator(String status) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'active':
      case 'approved':
      case 'completed':
      case 'success':
        statusColor = successColor;
        break;
      case 'pending':
      case 'in progress':
      case 'waiting':
        statusColor = warningColor;
        break;
      case 'inactive':
      case 'rejected':
      case 'failed':
      case 'error':
        statusColor = errorColor;
        break;
      default:
        statusColor = infoColor;
    }
    
    return BoxDecoration(
      color: statusColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: statusColor.withOpacity(0.3),
        width: 1,
      ),
    );
  }
}