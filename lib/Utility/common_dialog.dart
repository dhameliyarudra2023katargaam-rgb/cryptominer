import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'blue_card.dart';
import 'common_color.dart';
import 'common_text.dart';

class CommonDialog {
  static void show({
    required String title,
    required String message,
    bool isError = true,
    VoidCallback? onClose,
  }) {
    if (isError) {
      debugPrint("======== ERROR ========");
      debugPrint("Title: $title");
      debugPrint("Message: $message");
      debugPrint("=======================");
    }
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 320,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: CommonColor.greyCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isError
                    ? CommonColor.red.withValues(alpha: 0.3)
                    : CommonColor.green.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                  color: isError ? CommonColor.red : CommonColor.green,
                  size: 50,
                ),
                const SizedBox(height: 16),
                CommonText.h2(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                CommonText.body(
                  message,
                  style: const TextStyle(
                    color: CommonColor.greyColor,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                BlueCard(
                  width: double.infinity,
                  height: 44,
                  borderRadius: 22,
                  onTap: () {
                    Get.back();
                    if (onClose != null) {
                      onClose();
                    }
                  },
                  child: const CommonText.h3(
                    "Okay",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  static void showConfirmation({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = "Confirm",
    String cancelText = "Cancel",
    Color confirmColor = CommonColor.red,
  }) {
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 320,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: CommonColor.greyCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: CommonColor.red,
                  size: 50,
                ),
                const SizedBox(height: 16),
                CommonText.h2(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                CommonText.body(
                  message,
                  style: const TextStyle(
                    color: CommonColor.greyColor,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: CommonText.body(
                            cancelText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                          onConfirm();
                        },
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: confirmColor,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          alignment: Alignment.center,
                          child: CommonText.body(
                            confirmText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.5),
      barrierDismissible: true,
    );
  }
}

