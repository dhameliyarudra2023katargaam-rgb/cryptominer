import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../Utility/black_card.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_copy_clipboard.dart';
import '../../Utility/font_style.dart';
import '../../Utility/picture_path.dart';
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
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SvgPicture.asset(PicturePath.qrScannerImage, fit: BoxFit.contain),
              ),
              const SizedBox(height: 14),

              YellowCard(
                width: 370,
                height: 50,
                borderRadius: 25,
                onTap: () {

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