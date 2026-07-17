import 'dart:developer';
import 'package:cryptominer/Features/Wallet/total_balance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../Service/Ads/native_ads_service.dart';
import 'wallet_controller.dart';


import '../../Utility/black_card.dart';
import '../../Utility/blue_button.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_text.dart';
import '../../Utility/custom_appbar.dart';
import '../../Utility/image_const.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late final WalletController walletController;

  @override
  void initState() {
    super.initState();
    walletController = Get.put(WalletController());
    
    // Log the total balance when entering the screen
    final total = walletController.walletBalance['totalBalance'] ?? "0.00";
    log("Entered WalletScreen - Current Total Balance: $total");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          // header space
                    // padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          padding: const EdgeInsets.only(top: 0, left: 20, right: 20),
          child: CustomAppBar(
            title: "Wallet",
            fontSize: 26,
            leading: const SizedBox(width: 48),
            actions: [
              GestureDetector(
                onTap: () {
                  walletController.fetchWalletBalance();
                  walletController.fetchWalletTransactions();
                  walletController.fetchWithdrawalHistory();
                  Get.snackbar(
                    "Refreshing",
                    "Updating wallet details...",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: CommonColor.blue.withValues(alpha: 0.9),
                    colorText: Colors.white,
                    duration: const Duration(seconds: 1),
                  );
                },

              ),
            ],
          ),
        ),
       // header space
          // const SizedBox(height: 24),
        const SizedBox(height: 6),
        Expanded(
          child: SingleChildScrollView(
            // physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(alignment: Alignment.center, child: TotalBalance()),
          const SizedBox(height: 16),

          const Center(child: AppNativeAd()),
          const SizedBox(height: 12),

          Align(
            alignment: Alignment.center,
            child: GradientBorderContainer(
              width: 370,
              height: 80,
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CommonText.small(
                          "Total Mining Rewards",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(() {
                          final bonus = walletController.walletBalance['bonusBalance'] ?? "0.00000000";
                          return FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: CommonText.h3(
                              "$bonus BTC",
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  BlueButton(
                    text: "Claim",
                    width: 80,
                    height: 36,
                   // total balance & reward ads
                    onPressed: () => walletController.claimBonusReward(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          const SizedBox(
            height: 28,
            child: CommonText.h1(
              "History",
            ),
          ),
          const SizedBox(height: 14),

          Obx(() {
            if (walletController.isLoadingTransactions.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: CircularProgressIndicator(color: CommonColor.orange),
                ),
              );
            }
            final txs = walletController.transactions;
            if (txs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: CommonText.body(
                    "No transactions found",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }
            return Column(
               children: List.generate(txs.length, (index) {
                final tx = txs[index];
                final rawTitle = tx['type']?.toString() ?? "Mining reward";
                final title = rawTitle.toUpperCase() == 'BONUS' ? 'CLAIM' : rawTitle;
                final status = tx['status']?.toString() ?? "Pending";
                final rawAmount = tx['amount']?.toString() ?? "0.00000000";
                final double parsedAmount = double.tryParse(rawAmount) ?? 0.0;
                final String amount = parsedAmount.toStringAsFixed(18);
                final isPending = status.toLowerCase() == "pending";

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildHistoryItem(
                    title: title,
                    status: status,
                    value: amount,
                    isPending: isPending,
                  ),
                );
              }),
            );
          }),
          const SizedBox(height: 80),
        ],
      ),
      ),
      ),
      ],
    );
  }

  Widget _buildHistoryItem({
    required String title,
    required String status,
    required String value,
    required bool isPending,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: CommonColor.darkGreen,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset(
            ImageConst.archiveDownIcon,
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 20,
                child: CommonText.h3(
                  title,
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: 126,
                height: 15,
                child: CommonText.body(
                  status,
                  style: TextStyle(
                    color: isPending ? CommonColor.orange : CommonColor.green,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: CommonText.h3(
                value,
              ),
            ),
          ),
        ),
      ],
    );
  }
}