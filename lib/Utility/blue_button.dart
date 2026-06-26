import 'package:flutter/material.dart';

import 'common_color.dart';
import 'common_text.dart';
class BlueButton extends StatelessWidget {
  final String text;
  final String? subtitle;
  final VoidCallback onPressed;
  final double? width;
  final double? height;

  const BlueButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.subtitle,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: CommonColor.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.zero,
          elevation: 0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonText.body(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 1),
              CommonText.small(
                subtitle!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
