import 'package:cryptominer/Features/Wallet/withdrawal_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'wallet_controller.dart';
import '../Home/home_controller.dart';

import '../../Utility/black_card.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_text.dart';
import '../../Utility/app_custom_dialog.dart';

class TotalBalance extends StatelessWidget {
  const TotalBalance({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBorderContainer(
      width: 370,
      height: 130,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Total Balance",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      AppCustomDialog.show(
                        context: context,
                        title: "Virtual Balance Notice",
                        message: "This app uses virtual currency only. No real cryptocurrency, cash rewards, withdrawals, or investment returns are provided.",
                      );
                    },
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Obx(() {
                final rawBalance = Get.find<WalletController>().walletBalance['totalBalance'];
                double parsed = 0.0;
                if (rawBalance != null) {
                  parsed = double.tryParse(rawBalance.toString()) ?? 0.0;
                }
                final String displayBalance = parsed.toStringAsFixed(2);
                
                // Calculate monthly earnings based on active mining speed
                double speedGh = 0.0;
                if (Get.isRegistered<HomeController>()) {
                  speedGh = double.tryParse(Get.find<HomeController>().dashboardMiningSpeed.value) ?? 0.0;
                }
                double monthlyUsd = speedGh * 0.0000101;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText.h1(
                      "\$$displayBalance",
                      style: const TextStyle(
                        color: CommonColor.orange,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    CommonText.small(
                      "Est. Monthly: \$${monthlyUsd.toStringAsFixed(6)} / Month",
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                );
              }),
            ],
          ),
          InkWell(
            onTap: () => Get.to(
              () => const WithdrawalScreen(),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 300),
            ),
            borderRadius: BorderRadius.circular(8),
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
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Text(
                    "Claim Reward ( withdrawal )",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
