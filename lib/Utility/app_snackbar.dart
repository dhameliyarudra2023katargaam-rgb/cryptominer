import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'common_color.dart';

enum _SnackType { notice, success, error, info }

class AppSnackbar {
  AppSnackbar._();

  // ── NOTICE (grey/dark style) ───────────────
  static void notice(
    String message, {
    String title = "Notice",
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
  }) {
    _show(
      title: title,
      message: message,
      type: _SnackType.notice,
      duration: duration,
      position: position,
    );
  }

  // ── SUCCESS (green accent) ────────────────────────────────────────────────
  static void success(
    String message, {
    String title = "Success",
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
  }) {
    _show(
      title: title,
      message: message,
      type: _SnackType.success,
      duration: duration,
      position: position,
    );
  }

  // ── ERROR (red accent) ────────────────────────────────────────────────────
  static void error(
    String message, {
    String title = "Error",
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
  }) {
    _show(
      title: title,
      message: message,
      type: _SnackType.error,
      duration: duration,
      position: position,
    );
  }

  // ── INFO (blue accent) ────────────────────────────────────────────────────
  static void info(
    String message, {
    String title = "Info",
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
  }) {
    _show(
      title: title,
      message: message,
      type: _SnackType.info,
      duration: duration,
      position: position,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Internal builder
  // ─────────────────────────────────────────────────────────────────────────
  static void _show({
    required String title,
    required String message,
    required _SnackType type,
    required Duration duration,
    required SnackPosition position,
  }) {
    // Dismiss any existing snackbar first
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    final _SnackStyle style = _SnackStyle.from(type);

    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: style.backgroundColor,
      colorText: Colors.white,
      duration: duration,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      boxShadows: [
        BoxShadow(
          color: style.accentColor.withValues(alpha: 0.18),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
      borderColor: style.accentColor.withValues(alpha: 0.25),
      borderWidth: 1.2,
      icon: Padding(
        padding: const EdgeInsets.only(left: 4, right: 4),
        child: Icon(
          style.icon,
          color: style.accentColor,
          size: 22,
        ),
      ),
      shouldIconPulse: false,
      titleText: Text(
        title,
        style: TextStyle(
          color: style.accentColor,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
      ),
      animationDuration: const Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SnackStyle - type based color & icon
// ─────────────────────────────────────────────────────────────────────────────
class _SnackStyle {
  final Color backgroundColor;
  final Color accentColor;
  final IconData icon;

  const _SnackStyle({
    required this.backgroundColor,
    required this.accentColor,
    required this.icon,
  });

  factory _SnackStyle.from(_SnackType type) {
    switch (type) {
      case _SnackType.notice:
        return const _SnackStyle(
          backgroundColor: Color(0xFF1A1A1A),
          accentColor: Colors.white,
          icon: Icons.info_outline_rounded,
        );
      case _SnackType.success:
        return _SnackStyle(
          backgroundColor: const Color(0xFF0D2014),
          accentColor: CommonColor.green,
          icon: Icons.check_circle_outline_rounded,
        );
      case _SnackType.error:
        return _SnackStyle(
          backgroundColor: const Color(0xFF1F0808),
          accentColor: CommonColor.red,
          icon: Icons.error_outline_rounded,
        );
      case _SnackType.info:
        return _SnackStyle(
          backgroundColor: const Color(0xFF080F1F),
          accentColor: CommonColor.blue,
          icon: Icons.notifications_outlined,
        );
    }
  }
}
