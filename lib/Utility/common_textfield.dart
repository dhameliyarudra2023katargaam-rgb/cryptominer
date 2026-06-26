import 'package:flutter/material.dart';

import 'common_color.dart';
import 'font_style.dart';

class CommonTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextStyle? style;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final bool borderless;
  final ValueChanged<String>? onChanged;

  const CommonTextField({
    super.key,
    this.controller, // optional
    this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.style,
    this.decoration,
    this.keyboardType,
    this.borderless = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (borderless) {
      return TextField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        onTap: onTap,
        style: style ?? CommonFontStyles.heading3,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: decoration ??
            const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
      );
    }

    return TextField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      style: style ?? CommonFontStyles.body,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: decoration ??
          InputDecoration(
            hintText: hintText,
            hintStyle: CommonFontStyles.body.copyWith(
              color: Colors.white.withValues(alpha: 0.3),
            ),
            filled: true,
            fillColor: CommonColor.inputBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: CommonColor.blue,
                width: 1.5,
              ),
            ),
            suffixIcon: suffixIcon,
          ),
    );
  }
}