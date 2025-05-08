import 'package:flutter/material.dart';

class AdminTheme {
  // Primary colors
  static const Color primaryColor = Color(0xFF4A6B5D);
  static const Color backgroundColor = Color(0xFFE5E0D8);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF333333);
  static const Color accentColor = Color(0xFF8BAA91);
  
  // Text styles
  static const TextStyle headerTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle titleTextStyle = TextStyle(
    color: Color(0xFF333333),
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle subtitleTextStyle = TextStyle(
    color: Color(0xFF666666),
    fontSize: 14,
  );
  
  // Card theme
  static CardTheme cardTheme = CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    color: cardColor,
  );
  
  // App bar theme
  static AppBarTheme appBarTheme = const AppBarTheme(
    backgroundColor: primaryColor,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  );
  
  // Button theme
  static ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    ),
  );
  
  // Input decoration theme
  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
  
  // Get the complete theme
  static ThemeData get themeData {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: cardTheme,
      appBarTheme: appBarTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      inputDecorationTheme: inputDecorationTheme,
      useMaterial3: true,
    );
  }
  
  // Common card widget
  static Widget card({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
  
  // Common header widget
  static Widget header({
    required BuildContext context,
    required String title,
    List<Widget>? actions,
    bool showBackButton = true,
  }) {
    return Container(
      color: primaryColor,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          Text(
            title,
            style: headerTextStyle,
          ),
          const Spacer(),
          if (actions != null) ...actions,
        ],
      ),
    );
  }
}

// Extension to easily apply text styles
extension AdminTextStyles on BuildContext {
  TextStyle get adminHeaderTextStyle => AdminTheme.headerTextStyle;
  TextStyle get adminTitleTextStyle => AdminTheme.titleTextStyle;
  TextStyle get adminSubtitleTextStyle => AdminTheme.subtitleTextStyle;
}
