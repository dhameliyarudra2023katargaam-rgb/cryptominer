import 'package:cryptominer/Features/Wallet/withdrawal_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'wallet_controller.dart';

import '../../Utility/black_card.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_text.dart';
import '../../Utility/picture_path.dart';

class TotalBalance extends StatelessWidget {
  const TotalBalance({super.key});

  @override
  Widget build(BuildContext context) {

    return GradientBorderContainer(
      width: 370,
      height: 180,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText.small(
                "Total Balance",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Obx(() {
                final rawBalance = Get.find<WalletController>().walletBalance['totalBalance'];
                String formattedBalance = "0.000000000000000000";
                if (rawBalance != null) {
                  final String valStr = rawBalance.toString().trim();
                  if (!valStr.contains('.')) {
                    formattedBalance = "$valStr.000000000000000000";
                  } else {
                    final List<String> parts = valStr.split('.');
                    final String integerPart = parts[0];
                    String decimalPart = parts[1];
                    if (decimalPart.length > 18) {
                      decimalPart = decimalPart.substring(0, 18);
                    } else {
                      decimalPart = decimalPart.padRight(18, '0');
                    }
                    formattedBalance = "$integerPart.$decimalPart";
                  }
                }
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: CommonText.h1(
                    formattedBalance,
                    style: const TextStyle(
                      color: CommonColor.orange,
                    ),
                  ),
                );
              }),
            ],
          ),

          Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              color: CommonColor.darkRed.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CommonText.small(
                "ADS",
                style: const TextStyle(
                  color: CommonColor.red,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: SvgPicture.asset(
                          PicturePath.convertIcon,
                          width: 18,
                          height: 18,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Padding(
                        padding: EdgeInsets.only(top: 3),
                        child: CommonText.h3(
                          "Convert",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => Get.to(
                        () => const WithdrawalScreen(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 12),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: SvgPicture.asset(
                          PicturePath.withdrawalIcon,
                          width: 18,
                          height: 18,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Padding(
                        padding: EdgeInsets.only(top: 3),
                        child: CommonText.h3(
                          "Withdrawal",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
