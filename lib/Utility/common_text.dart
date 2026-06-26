import 'package:flutter/material.dart';

import 'font_style.dart';

enum FontStyleType {
  h1,
  h2,
  h3,
  body,
  small,
  custom,
}

class CommonText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final FontStyleType styleType;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  const CommonText(
      this.text, {
        super.key,
        this.style,
        this.textAlign,
        this.overflow,
        this.maxLines,
      }) : styleType = FontStyleType.custom;

  const CommonText.h1(
      this.text, {
        super.key,
        this.style,
        this.textAlign,
        this.overflow,
        this.maxLines,
      }) : styleType = FontStyleType.h1;

  const CommonText.h2(
      this.text, {
        super.key,
        this.style,
        this.textAlign,
        this.overflow,
        this.maxLines,
      }) : styleType = FontStyleType.h2;

  const CommonText.h3(
      this.text, {
        super.key,
        this.style,
        this.textAlign,
        this.overflow,
        this.maxLines,
      }) : styleType = FontStyleType.h3;

  const CommonText.body(
      this.text, {
        super.key,
        this.style,
        this.textAlign,
        this.overflow,
        this.maxLines,
      }) : styleType = FontStyleType.body;

  const CommonText.small(
      this.text, {
        super.key,
        this.style,
        this.textAlign,
        this.overflow,
        this.maxLines,
      }) : styleType = FontStyleType.small;

  @override
  Widget build(BuildContext context) {
    TextStyle baseStyle;
    switch (styleType) {
      case FontStyleType.h1:
        baseStyle = CommonFontStyles.heading1;
        break;
      case FontStyleType.h2:
        baseStyle = CommonFontStyles.heading2;
        break;
      case FontStyleType.h3:
        baseStyle = CommonFontStyles.heading3;
        break;
      case FontStyleType.body:
        baseStyle = CommonFontStyles.body;
        break;
      case FontStyleType.small:
        baseStyle = CommonFontStyles.small;
        break;
      case FontStyleType.custom:
        baseStyle = const TextStyle();
        break;
    }

    final finalStyle = style != null ? baseStyle.merge(style) : baseStyle;

    return Text(
      text,
      style: finalStyle,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
