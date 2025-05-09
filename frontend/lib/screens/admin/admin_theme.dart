import 'package:flutter/material.dart';
import '../../core/constants/dashboard_theme.dart';

class AdminTheme {
  // Primary colors - using dashboard theme for consistency
  static const Color primaryColor = DashboardTheme.primaryColor;
  static const Color backgroundColor = DashboardTheme.backgroundColor;
  static const Color cardColor = DashboardTheme.cardColor;
  static const Color textColor = DashboardTheme.textColor;
  static const Color accentColor = DashboardTheme.accentColor;
  static const Color sidebarColor = DashboardTheme.sidebarColor;
  static const Color sidebarActiveColor = DashboardTheme.sidebarActiveColor;
  static const Color sidebarHoverColor = DashboardTheme.sidebarHoverColor;
  
  // Text styles
  static TextStyle get headerTextStyle => const TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  
  static TextStyle get titleTextStyle => DashboardTheme.subheadingStyle;
  
  static TextStyle get subtitleTextStyle => DashboardTheme.bodyStyle;
  
  // Card theme
  static CardTheme cardTheme = CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    color: cardColor,
  );
  
  // App bar theme
  static AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: primaryColor,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: headerTextStyle,
    iconTheme: const IconThemeData(color: Colors.white),
  );
  
  // Button theme
  static ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
    style: DashboardTheme.primaryButtonStyle,
  );
  
  // Input decoration theme
  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
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
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: cardColor,
        background: backgroundColor,
      ),
      useMaterial3: true,
    );
  }
  
  // Common card widget with hover effect
  static Widget card({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    Color? accentColorOverride,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: DashboardTheme.cardDecorationWithHover(isHovered: isHovered),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(16.0),
                  child: child,
                ),
              ),
            ),
          ),
        );
      }
    );
  }
  
  // Dashboard card with accent color
  static Widget dashboardCard({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    Color? accentColorOverride,
  }) {
    return Container(
      decoration: DashboardTheme.dashboardCardDecoration(
        accentColorOverride: accentColorOverride,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16.0),
            child: child,
          ),
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
      decoration: BoxDecoration(
        color: primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
  
  // Status badge
  static Widget statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: DashboardTheme.statusIndicator(status),
      child: Text(
        status,
        style: TextStyle(
          color: _getStatusColor(status),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
  
  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'approved':
      case 'completed':
      case 'success':
        return DashboardTheme.successColor;
      case 'pending':
      case 'in progress':
      case 'waiting':
        return DashboardTheme.warningColor;
      case 'inactive':
      case 'rejected':
      case 'failed':
      case 'error':
        return DashboardTheme.errorColor;
      default:
        return DashboardTheme.infoColor;
    }
  }
}

// Extension to easily apply text styles
extension AdminTextStyles on BuildContext {
  TextStyle get adminHeaderTextStyle => AdminTheme.headerTextStyle;
  TextStyle get adminTitleTextStyle => AdminTheme.titleTextStyle;
  TextStyle get adminSubtitleTextStyle => AdminTheme.subtitleTextStyle;
}
