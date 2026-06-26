import 'package:flutter/material.dart';

class NextArrowIcon extends StatelessWidget {
  final double size;

  const NextArrowIcon({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.chevron_right_rounded,
        color: Colors.black,
        size: size * 0.7,
      ),
    );
  }
}
