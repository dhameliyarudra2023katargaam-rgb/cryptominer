import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'common_color.dart';
import 'common_text.dart';

class AppCustomDialog {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = "OK",
    VoidCallback? onPressed,
  }) {
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 360,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: CommonColor.greyCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CommonText.h2(
                  title,
                  style: const TextStyle(
                    color: CommonColor.orange,
                    fontSize: 22,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                CommonText.body(
                  message,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () {
                    Get.back();
                    if (onPressed != null) {
                      onPressed();
                    }
                  },
                  child: Container(
                    width: 140,
                    height: 48,
                    decoration: BoxDecoration(
                      color: CommonColor.blue,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.6),
      barrierDismissible: true,
    );
  }
}
