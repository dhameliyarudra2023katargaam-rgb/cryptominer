import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../Utility/black_card.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_copy_clipboard.dart';
import '../../Utility/common_text.dart';
import '../../Utility/custom_appbar.dart';
import '../../Utility/font_style.dart';
import '../../Utility/image_const.dart';

class WithdrawalStatusScreen extends StatelessWidget {
  final String network;
  final String address;
  final String amount;
  final String initiationTime;
  final String withdrawId;

  const WithdrawalStatusScreen({
    super.key,
    this.network = "Lighting Network",
    this.address = "example@demo.com",
    this.amount = "1 BTC",
    this.initiationTime = "Jun 062026 05:06:56",
    this.withdrawId = "854646546546",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColor.background,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: "Withdrawal",
              fontSize: 26,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    // Yellow circle clock container (90x90)
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: CommonColor.orange,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        ImageConst.pendingIcon,
                        width: 54,
                        height: 54,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    const CommonText.h1(
                      "Pending",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const CommonText.h1(
                      "We will process it",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Status Card (w=370)
                    Align(
                      alignment: Alignment.center,
                      child: GradientBorderContainer(
                        width: 370,
                        borderRadius: 16,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildCardRow(context, "Transfer network", network),
                            const Divider(height: 20, color: Color(0xFF242424)),
                            _buildCardRow(context, "Address", address),
                            const Divider(height: 20, color: Color(0xFF242424)),
                            _buildCardRow(context, "Amount", amount),
                            const Divider(height: 20, color: Color(0xFF242424)),
                            _buildCardRow(context, "Initiatin Time", initiationTime),
                            const Divider(height: 20, color: Color(0xFF242424)),
                            _buildCardRow(context, "Withrow ID", withdrawId, showCopy: true),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Support Footer
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "If you have any questions about this translation.\nplease contact us via email at ",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.6),
                              fontFamily: CommonFontStyles.fontFamily,
                              height: 1.4,
                            ),
                          ),
                          TextSpan(
                            text: "help@btcminer.com",
                            style: TextStyle(
                              fontSize: 14,
                              color: CommonColor.blue,
                              fontWeight: FontWeight.normal,
                              fontFamily: CommonFontStyles.fontFamily,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
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

  Widget _buildCardRow(BuildContext context, String label, String value, {bool showCopy = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CommonText.h3(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: CommonText.h3(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showCopy) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {

                    CommonCopyClipboard.copy(
                      context,
                      value,
                      message: "Withrow ID copied",
                    );
                  },
                  child: SvgPicture.asset(
                    ImageConst.copyIcon,
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
