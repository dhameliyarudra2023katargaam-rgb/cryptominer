import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'common_color.dart';

class SvgBase64Renderer extends StatelessWidget {
  final String assetPath;
  final BoxFit fit;
  final double? width;
  final double? height;

  const SvgBase64Renderer({
    super.key,
    required this.assetPath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  Future<Uint8List> _decodeBase64FromSvg() async {
    final svgString = await rootBundle.loadString(assetPath);
    const startKey = "data:image/png;base64,";
    final startIdx = svgString.indexOf(startKey);
    if (startIdx == -1) {
      throw Exception("Base64 pattern not found in SVG");
    }
    final endIdx = svgString.indexOf('"', startIdx + startKey.length);
    if (endIdx == -1) {
      throw Exception("Closing quote not found in SVG");
    }
    final base64Str = svgString.substring(startIdx + startKey.length, endIdx).replaceAll(RegExp(r'\s+'), '');
    return base64.decode(base64Str);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _decodeBase64FromSvg(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: CommonColor.orange));
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
        }
        return Image.memory(
          snapshot.data!,
          width: width,
          height: height,
          fit: fit,
        );
      },
    );
  }
}
