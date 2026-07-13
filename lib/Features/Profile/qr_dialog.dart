import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../Utility/black_card.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_copy_clipboard.dart';
import '../../Utility/font_style.dart';
import '../../Utility/image_const.dart';
import '../../Utility/yellow_card.dart';

class QrDialog {
  static void show(BuildContext context, {required String referralLink}) {
    Get.bottomSheet(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          decoration: const BoxDecoration(
            color: CommonColor.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "Share your QR-code",
                style: CommonFontStyles.heading2,
              ),
              const SizedBox(height: 10),

              Text(
                "When your friend scans the code and signs up,\nthey'll automatically become your referral",
                textAlign: TextAlign.center,
                style: CommonFontStyles.body.copyWith(
                  color: const Color(0xFFB0B0B0),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),

              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: QrImageView(
                  data: referralLink,
                  version: QrVersions.auto,
                  size: 248.0,
                ),
              ),
              const SizedBox(height: 14),

              YellowCard(
                width: 370,
                height: 50,
                borderRadius: 25,
                onTap: () async {
                  try {
                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return  Center(
                          child: CircularProgressIndicator(color: CommonColor.orange),
                        );
                      },
                    );

                    final String text =
                        "Join this app using my referral link and earn rewards!\nReferral Link: $referralLink";
                    File? qrImageFile;

                    try {
                      final qrValidationResult = QrValidator.validate(
                        data: referralLink,
                        version: QrVersions.auto,
                        errorCorrectionLevel: QrErrorCorrectLevel.L,
                      );

                      if (qrValidationResult.status == QrValidationStatus.valid) {
                        final qrCode = qrValidationResult.qrCode;
                        final painter = QrPainter.withQr(
                          qr: qrCode!,
                          color: const Color(0xFF000000),
                          emptyColor: const Color(0xFFFFFFFF),
                          gapless: true,
                        );

                        final tempDir = await getTemporaryDirectory();
                        final ts = DateTime.now().millisecondsSinceEpoch.toString();
                        final path = '${tempDir.path}/qr_$ts.png';
                        final picData = await painter.toImageData(2048, format: ImageByteFormat.png);
                        if (picData != null) {
                          qrImageFile = File(path);
                          await qrImageFile.writeAsBytes(picData.buffer.asUint8List());
                        }
                      }
                    } catch (e) {
                      // Silently fall back to text only if image generation fails
                    }

                    // Dismiss loading indicator
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }

                    if (qrImageFile != null) {
                      final xFile = XFile(qrImageFile.path);
                      await Share.shareXFiles([xFile], text: text);
                    } else {
                      await Share.share(text);
                    }
                  } catch (e) {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Unable to share referral. Please try again.")),
                    );
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.share_outlined, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Share",
                      style: CommonFontStyles.heading3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: () {
                  CommonCopyClipboard.copy(
                    context,
                    referralLink,
                    message: "Referral link copied",
                  );
                },
                borderRadius: BorderRadius.circular(25),
                child: GradientBorderContainer(
                  width: 370,
                  height: 50,
                  borderRadius: 25,
                  backgroundColor: CommonColor.darkGray,
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.copy_outlined, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Copy link",
                        style: CommonFontStyles.heading3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}