import 'package:cryptominer/Features/Wallet/total_balance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'wallet_controller.dart';

import '../../Utility/black_card.dart';
import '../../Utility/blue_button.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_text.dart';
import '../../Utility/custom_appbar.dart';
import '../../Utility/picture_path.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletController walletController = Get.put(WalletController());
    return SingleChildScrollView(
      // physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAppBar(
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
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: SvgPicture.asset(
                      PicturePath.refreshIcon,
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Align(alignment: Alignment.center, child: TotalBalance()),
          const SizedBox(height: 16),

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
                        CommonText.small(
                          "Bonus Miner Rewards",
                          style: const TextStyle(
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
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          const SizedBox(
            height: 28,
            child: CommonText.h1(
              "History",
            ),
          ),
          const SizedBox(height: 16),

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
                final title = tx['type']?.toString() ?? "Mining reward";
                final status = tx['status']?.toString() ?? "Pending";
                final rawAmount = tx['amount']?.toString() ?? "0.00000000";
                final double parsedAmount = double.tryParse(rawAmount) ?? 0.0;
                final String amount = parsedAmount.toStringAsFixed(8);
                final isPending = status.toLowerCase() == "pending";

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildHistoryItem(
                    title: title,
                    status: status,
                    value: "$amount BTC",
                    isPending: isPending,
                  ),
                );
              }),
            );
          }),
          const SizedBox(height: 80),
        ],
      ),
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
            PicturePath.archiveDownIcon,
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
        SizedBox(
          width: 145,
          height: 20,
          child: Align(
            alignment: Alignment.centerRight,
            child: CommonText.h3(
              value,
            ),
          ),
        ),
      ],
    );
  }
}