import 'package:cryptominer/Features/Wallet/withdrawal_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'wallet_controller.dart';
import '../../Service/Ads/banner_ads_service.dart';

import '../../Utility/black_card.dart';
import '../../Utility/blue_card.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_text.dart';
import '../../Utility/common_textfield.dart';
import '../../Utility/custom_appbar.dart';
import '../../Utility/font_style.dart';
import '../../Utility/image_const.dart';
import '../../Utility/app_snackbar.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final String _selectedMethod = 'Lighting address';
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
            const Padding(
              padding: EdgeInsets.only(top: 0, left: 20, right: 20),
              child: CustomAppBar(
                title: "Claim Reward",
                titleWidth: 228,
                titleHeight: 24,
                fontSize: 24,
                // fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Virtual Balance Label
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Virtual Balance",
                        style: TextStyle(
                          fontSize: 20,
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
                            fontSize: 22,
                            fontWeight: FontWeight.normal,
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
                    const SizedBox(height: 20),

                    // Select Collection Wallet Label
                    const CommonText.h2(
                      "Select Collection wallet",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
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
                              ImageConst.btcWalletIcon,
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
                    const SizedBox(height: 20),

                    // Address Label
                    const CommonText.h3(
                      "Wallet Address",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Address Input Box
                    Align(
                      alignment: Alignment.center,
                      child: GradientBorderContainer(
                        width: 370,
                        height: 55,
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Center(
                          child: CommonTextField(
                            controller: _addressController,
                            borderless: true,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: CommonFontStyles.fontFamily,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              hintText: "Enter your wallet address",
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
                    const SizedBox(height: 32),

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

                                String address = _addressController.text.trim();
                                if (address.isEmpty) {
                                  Get.snackbar(
                                    "Required",
                                    "Please enter your wallet address",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                                    colorText: Colors.white,
                                  );
                                  return;
                                }

                                walletController.submitWithdrawal(amount, address, _selectedMethod).then((success) {
                                  if (success) {
                                    Get.to(
                                      () => WithdrawalStatusScreen(
                                        network: _selectedMethod,
                                        address: address,
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
                                "Claim Rewards!",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
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
            const AppBanner(),
          ],
        ),
      ),
    );
  }
}
