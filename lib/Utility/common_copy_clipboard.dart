import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'common_color.dart';
import 'common_text.dart';
import 'font_style.dart';

class CommonCopyClipboard {
  static void copy(BuildContext context, String text, {String? message}) {
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: CommonColor.green,
              size: 20,
            ),
            const SizedBox(width: 8),
            CommonText.body(
              message ?? "Copied to clipboard",
              style: CommonFontStyles.body,
            ),
          ],
        ),
        backgroundColor: CommonColor.greyCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
