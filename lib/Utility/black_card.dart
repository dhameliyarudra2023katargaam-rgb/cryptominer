import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'common_color.dart';

class GradientBorderContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double strokeWidth;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final AlignmentGeometry? alignment;
  final Gradient? gradient;

  const GradientBorderContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    required this.borderRadius,
    this.strokeWidth = 1.2,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.alignment,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _GradientBorderPainter(
        strokeWidth: strokeWidth,
        borderRadius: borderRadius,
        customGradient: gradient,
      ),
      child: Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        alignment: alignment,
        decoration: BoxDecoration(
          color: backgroundColor ?? CommonColor.glassWhite,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child,
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double strokeWidth;
  final double borderRadius;
  final Gradient? customGradient;

  _GradientBorderPainter({
    required this.strokeWidth,
    required this.borderRadius,
    this.customGradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final double w = size.width;
    final double h = size.height;

    final Offset from = Offset.zero;
    final double factor = (2 * h * w) / (h * h + w * w);
    final Offset to = Offset(h * factor, w * factor);

    final Shader shader =
        customGradient?.createShader(rect) ??
            ui.Gradient.linear(
              from,
              to,
              [
                Colors.white.withValues(alpha: 0.35),
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.35),
              ],
              const [0.0, 0.5, 1.0],
            );

    final paint = Paint()
      ..shader = shader
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(borderRadius),
    );

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.customGradient != customGradient;
  }
}
