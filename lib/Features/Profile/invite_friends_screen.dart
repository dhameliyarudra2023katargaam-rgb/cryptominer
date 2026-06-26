import 'package:flutter/material.dart';
import '../../Utility/black_card.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_copy_clipboard.dart';
import '../../Utility/custom_appbar.dart';
import '../../Utility/font_style.dart';
import '../../Utility/picture_path.dart';
import '../../Utility/yellow_card.dart';
import 'qr_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';


class InviteFriendsScreen extends StatefulWidget {
  const InviteFriendsScreen({super.key});

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen> {
  final String referralCode = "COIN99";
  final String referralLink = "https://cryptominer.com/ref/COIN99";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColor.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),

                    const CustomAppBar(title: "Invite your friends"),

                    const SizedBox(height: 36),

                    SizedBox(
                      width: 178,
                      height: 40,
                      child: Text(
                        "Invite to your friends and\nget a extra coins.",
                        textAlign: TextAlign.center,
                        style: CommonFontStyles.heading3.copyWith(height: 1.25),
                      ),
                    ),

                    const SizedBox(height: 36),

                    InkWell(
                      onTap: () {
                        CommonCopyClipboard.copy(
                          context,
                          referralCode,
                          message: "Referral code copied",
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: GradientBorderContainer(
                        width: 370,
                        height: 50,
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Referral Code",
                              style: CommonFontStyles.heading3,
                            ),
                            SvgPicture.asset(

                              PicturePath.copyIcon,
                              width: 18,
                              height: 18,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    InkWell(
                      onTap: () {
                        CommonCopyClipboard.copy(
                          context,
                          referralLink,
                          message: "Referral link copied",
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: GradientBorderContainer(
                        width: 370,
                        height: 50,
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Referral link",
                              style: CommonFontStyles.heading3,
                            ),
                            SvgPicture.asset(
                              PicturePath.copyIcon,
                              width: 18,
                              height: 18,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    YellowCard(
                      width: 370,
                      height: 54,
                      borderRadius: 27,
                      onTap: () {
                        QrDialog.show(context, referralLink: referralLink);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            size: 24,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text("Open QR-code", style: CommonFontStyles.heading2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}