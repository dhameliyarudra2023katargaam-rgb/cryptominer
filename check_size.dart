import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final inputPath = 'assets/logo/app_logo.png';
  final inputImage = img.decodeImage(File(inputPath).readAsBytesSync());
  if (inputImage == null) {
    print('Failed to decode image');
    return;
  }
  print('app_logo.png size: \${inputImage.width}x\${inputImage.height}');
}
