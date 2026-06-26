import 'package:flutter/material.dart';

import 'common_color.dart';

class MyAvtar extends StatelessWidget {
  final double radius;
  final String? imageUrl;
  final VoidCallback? onTap;

  const MyAvtar({super.key, this.radius = 60.0, this.imageUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: const BoxDecoration(
          color: CommonColor.blue,
          shape: BoxShape.circle,
        ),
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? ClipOval(
          child: Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
            const SizedBox(),
          ),
        )
            : Icon(
          Icons.person,
          color: Colors.white,
          size: radius * 1.15,
        ),
      ),
    );
  }
}
