import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  // Theme shortcuts
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  // MediaQuery shortcuts
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => mediaQuery.padding;
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  // Navigation shortcuts
  NavigatorState get navigator => Navigator.of(this);

  void pop<T>([T? result]) => navigator.pop(result);

  void push(Widget page) =>
      navigator.push(MaterialPageRoute(builder: (_) => page));

  void pushNamed(String routeName, {Object? arguments}) =>
      navigator.pushNamed(routeName, arguments: arguments);

  void pushReplacement(Widget page) =>
      navigator.pushReplacement(MaterialPageRoute(builder: (_) => page));

  // SnackBar shortcuts
  void showSnackBar(
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: colorScheme.error);
  }

  void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.green);
  }

  // Dialog shortcuts
  Future<T?> showAppDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (_) => child,
    );
  }

  // Responsive breakpoints
  bool get isMobile => screenWidth < 768;
  bool get isTablet => screenWidth >= 768 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;

  // Safe area helpers
  double get statusBarHeight => padding.top;
  double get bottomNavBarHeight => padding.bottom;
}
