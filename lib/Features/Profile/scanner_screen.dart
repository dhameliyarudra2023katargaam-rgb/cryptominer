import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../Utility/common_color.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController scannerController = MobileScannerController();
  bool isScanCompleted = false;

  void handleBarcode(BarcodeCapture capture) {
    if (isScanCompleted) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        setState(() {
          isScanCompleted = true;
        });

        scannerController.stop();
        Get.back(result: code);
      }
    }
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full Screen Camera View
          MobileScanner(
            controller: scannerController,
            onDetect: handleBarcode,
          ),
          
          // Dark Overlay with transparent center cutout
          const QRScannerOverlay(overlayColour: Colors.black54),
          
          // AppBar and Flashlight Toggle
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  const Text(
                    "Scan QR Code",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          
          // Bottom Instructions
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded, 
                      color: Colors.white, 
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Align QR code within the frame to scan",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A custom widget to draw a dark overlay with a clear square hole in the center
class QRScannerOverlay extends StatelessWidget {
  const QRScannerOverlay({super.key, required this.overlayColour});

  final Color overlayColour;

  @override
  Widget build(BuildContext context) {
    double scanArea = 260; // Size of the transparent square
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(overlayColour, BlendMode.srcOut),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: scanArea,
                  width: scanArea,
                  decoration: BoxDecoration(
                    color: Colors.red, // This color is clipped out
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Draw the corners of the scanner box
        Align(
          alignment: Alignment.center,
          child: CustomPaint(
            foregroundPainter: BorderPainter(),
            child: SizedBox(
              width: scanArea + 10,
              height: scanArea + 10,
            ),
          ),
        ),
      ],
    );
  }
}

/// A custom painter to draw the 4 corner borders (L-shapes) of the scanner
class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const width = 4.0;
    const radius = 20.0;
    const tRadius = 35.0; // Length of the corner lines

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(radius));
    
    // Create 4 clipping rectangles at each corner
    final clippingRect0 = Rect.fromLTWH(0, 0, tRadius, tRadius);
    final clippingRect1 = Rect.fromLTWH(size.width - tRadius, 0, tRadius, tRadius);
    final clippingRect2 = Rect.fromLTWH(0, size.height - tRadius, tRadius, tRadius);
    final clippingRect3 = Rect.fromLTWH(size.width - tRadius, size.height - tRadius, tRadius, tRadius);

    final path = Path()
      ..addRect(clippingRect0)
      ..addRect(clippingRect1)
      ..addRect(clippingRect2)
      ..addRect(clippingRect3);

    canvas.clipPath(path);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = CommonColor.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
