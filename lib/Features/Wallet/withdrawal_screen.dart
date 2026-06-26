import 'package:cryptominer/Features/Wallet/withdrawal_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'wallet_controller.dart';

import '../../Utility/black_card.dart';
import '../../Utility/blue_card.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_text.dart';
import '../../Utility/common_textfield.dart';
import '../../Utility/custom_appbar.dart';
import '../../Utility/font_style.dart';
import '../../Utility/picture_path.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  String _selectedMethod = 'Lighting address';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final WalletController walletController = Get.find<WalletController>();

  @override
  void dispose() {
    _amountController.dispose();
    _addressController.dispose();
    super.dispose();
  }

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
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Virtual Balance Label
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Virtual Balance",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                          fontFamily: CommonFontStyles.fontFamily,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Balance Amount
                    Center(
                      child: Obx(() {
                        final rawBalance = walletController.walletBalance['withdrawableBalance'] ??
                                        walletController.walletBalance['totalBalance'] ?? "0";
                        final double parsedBalance = double.tryParse(rawBalance.toString()) ?? 0.0;
                        final String displayBalance = parsedBalance.toStringAsFixed(14);
                        return Text(
                          displayBalance,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: CommonFontStyles.fontFamily,
                          ),
                          textAlign: TextAlign.center,
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    // Disclaimer Paragraph
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "This app provides a simulated mining experience only. All coins, rewards, balances, and earnings displayed are virtual estimates and have no real-world monetary value. The app does not offer real cryptocurrency, real cash earnings, real withdrawals, or investment services.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            height: 1.3,
                            fontFamily: CommonFontStyles.fontFamily,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Select Collection Wallet Label
                    const CommonText.h2(
                      "Select Collection wallet",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Wallet Selector Box
                    Align(
                      alignment: Alignment.center,
                      child: GradientBorderContainer(
                        width: 370,
                        height: 55,
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              PicturePath.btcWalletIcon,
                              width: 32,
                              height: 32,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 12),
                            const CommonText.h3(
                              "Coins Wallet",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Amount Label
                    const CommonText.h3(
                      "Amount",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Amount Input Box
                    Align(
                      alignment: Alignment.center,
                      child: GradientBorderContainer(
                        width: 370,
                        height: 55,
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Center(
                          child: CommonTextField(
                            controller: _amountController,
                            borderless: true,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: CommonFontStyles.fontFamily,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontFamily: CommonFontStyles.fontFamily,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Min Balance Requirement Text
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Text(
                        "Min. 1 Virtual Balance Amount",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontFamily: CommonFontStyles.fontFamily,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // History Title
                    const CommonText.h1(
                      "History",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Today Title
                    const CommonText.h2(
                      "Today",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Obx(() {
                      if (walletController.isLoadingWithdrawalHistory.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.0),
                            child: CircularProgressIndicator(color: CommonColor.orange),
                          ),
                        );
                      }
                      final list = walletController.withdrawalHistory;
                      if (list.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(
                            child: CommonText.body(
                              "No withdrawal history found",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: List.generate(list.length, (index) {
                          final item = list[index];
                          final type = item['type']?.toString() ?? "Mining reward";
                          final status = item['status']?.toString() ?? "Pending";
                          final rawAmount = item['amount']?.toString() ?? "0.00000000";
                          final double parsedAmount = double.tryParse(rawAmount) ?? 0.0;
                          final String amount = parsedAmount.toStringAsFixed(11);
                          final isPending = status.toLowerCase() == "pending";

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isPending 
                                        ? const Color(0xFFEB4335).withValues(alpha: 0.1) 
                                        : const Color(0xFF00A713).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: SvgPicture.asset(
                                    isPending ? PicturePath.redArchiveIcon : PicturePath.archiveDownIcon,
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.contain,
                                    colorFilter: isPending
                                        ? null
                                        : const ColorFilter.mode(
                                            CommonColor.green,
                                            BlendMode.srcIn,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          CommonText.h3(
                                            type,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          CommonText.h3(
                                            amount,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      CommonText.body(
                                        status,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isPending ? CommonColor.orange : CommonColor.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      );
                    }),
                    const SizedBox(height: 40),

                    // Withdrawal button
                    Align(
                      alignment: Alignment.center,
                      child: Obx(() => walletController.isSubmittingWithdrawal.value
                          ? const CircularProgressIndicator(color: CommonColor.blue)
                          : BlueCard(
                              width: 370,
                              height: 54,
                              borderRadius: 27,
                              onTap: () {
                                String amountText = _amountController.text.trim();
                                if (amountText.isEmpty) {
                                  Get.snackbar(
                                    "Required",
                                    "Please enter amount to withdraw",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                                double? amount = double.tryParse(amountText);
                                if (amount == null || amount <= 0) {
                                  Get.snackbar(
                                    "Error",
                                    "Please enter a valid amount",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                                // Check against available withdrawable balance
                                final rawBalance = walletController.walletBalance['withdrawableBalance'] ??
                                    walletController.walletBalance['totalBalance'] ??
                                    "0";
                                final double availableBalance = double.tryParse(rawBalance.toString()) ?? 0.0;
                                if (amount > availableBalance) {
                                  Get.snackbar(
                                    "Insufficient Balance",
                                    "You only have ${availableBalance.toStringAsFixed(14)} available to withdraw",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                                    colorText: Colors.white,
                                  );
                                  return;
                                }

                                const String dummyAddress = "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh";
                                walletController.submitWithdrawal(amount, dummyAddress, _selectedMethod).then((success) {
                                  if (success) {
                                    Get.to(
                                      () => WithdrawalStatusScreen(
                                        network: _selectedMethod,
                                        address: dummyAddress,
                                        amount: amountText,
                                        initiationTime: DateTime.now().toLocal().toString().substring(0, 19),
                                        withdrawId: walletController.lastWithdrawalId.value,
                                      ),
                                      transition: Transition.rightToLeft,
                                      duration: const Duration(milliseconds: 300),
                                    );
                                  }
                                });
                              },
                              child: const CommonText.h2(
                                "Withdrawal",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioButton(String value) {
    final bool isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? CommonColor.blue : Colors.white,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(4),
            child: isSelected
                ? Container(
              decoration: const BoxDecoration(
                color: CommonColor.blue,
                shape: BoxShape.circle,
              ),
            )
                : null,
          ),
          const SizedBox(width: 8),
          CommonText.h2(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}