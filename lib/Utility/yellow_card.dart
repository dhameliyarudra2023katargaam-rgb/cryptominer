import 'package:flutter/material.dart';

import 'common_color.dart';

class YellowCard extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final VoidCallback? onTap;

  const YellowCard({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height = 54,
    this.borderRadius = 27,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: CommonColor.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
        child: child,
      ),
    );
  }
}
