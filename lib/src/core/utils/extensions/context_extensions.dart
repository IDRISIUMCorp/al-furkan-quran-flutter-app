import 'package:flutter/material.dart';

/// Al-Furkan BuildContext Extensions — Convenience methods for theme access
extension BuildContextExtensions on BuildContext {
  // ── Theme ──
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // ── MediaQuery ──
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);
  double get statusBarHeight => padding.top;
  double get bottomNavBarHeight => padding.bottom;
  bool get isSmallScreen => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;

  // ── Navigation ──
  void pop<T extends Object?>([T? result]) => Navigator.of(this).pop(result);
  bool canPop() => Navigator.of(this).canPop();

  // ── SnackBar ──
  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);

  void showSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        backgroundColor: Theme.of(this).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
