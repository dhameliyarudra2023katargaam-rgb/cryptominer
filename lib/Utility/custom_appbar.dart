import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'font_style.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final double titleWidth;
  final double titleHeight;
  final double fontSize;
  final FontWeight fontWeight;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.titleWidth = 210,
    this.titleHeight = 24,
    this.fontSize = 24,
    this.fontWeight = FontWeight.w500,
  });

  @override
  Widget build(BuildContext context) {
    final Widget leftWidget =
        leading ??
            (Navigator.of(context).canPop()
                ? IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: Colors.white,
                size: 32,
              ),
            )
                : const SizedBox(width: 48));

    final Widget rightWidget = (actions != null && actions!.isNotEmpty)
        ? actions!.first
        : const SizedBox(width: 48);

    return SizedBox(
      height: preferredSize.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 48, height: 48, child: Center(child: leftWidget)),

          Expanded(
            child: Center(
              child: SizedBox(
                width: titleWidth,
                height: titleHeight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      fontFamily: CommonFontStyles.fontFamily,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: 48, height: 48, child: Center(child: rightWidget)),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
