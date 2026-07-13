import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../Utility/image_const.dart';
import '../../Utility/common_color.dart';

class ProfitImageSlider extends StatefulWidget {
  const ProfitImageSlider({super.key});

  @override
  State<ProfitImageSlider> createState() => _ProfitImageSliderState();
}

class _ProfitImageSliderState extends State<ProfitImageSlider> {
  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();
  final List<Uint8List?> _decodedBytes = [null, null, null];
  bool _isLoading = true;

  final List<String> _images = [
    ImageConst.maximumProfitSvg1,
    ImageConst.maximumProfitSvg2,
    ImageConst.maximumProfitSvg3,
  ];

  @override
  void initState() {
    super.initState();
    _loadAllImages();
  }

  Future<void> _loadAllImages() async {
    try {
      for (int i = 0; i < _images.length; i++) {
        final svgString = await rootBundle.loadString(_images[i]);
        const startKey = "data:image/png;base64,";
        final startIdx = svgString.indexOf(startKey);
        if (startIdx != -1) {
          final endIdx = svgString.indexOf('"', startIdx + startKey.length);
          if (endIdx != -1) {
            final base64Str = svgString
                .substring(startIdx + startKey.length, endIdx)
                .replaceAll(RegExp(r'\s+'), '');
            _decodedBytes[i] = base64.decode(base64Str);
          }
        }
      }
    } catch (e) {
      // error handling
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 185,
        child: Center(
          child: CircularProgressIndicator(
            color: CommonColor.orange,
          ),
        ),
      );
    }

    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _controller,
          itemCount: _images.length,
          options: CarouselOptions(
            height: 185,
            viewportFraction: 0.85,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            final bytes = _decodedBytes[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: bytes != null
                  ? Image.memory(
                      bytes,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _images.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentIndex == entry.key ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentIndex == entry.key
                      ? CommonColor.orange
                      : Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
