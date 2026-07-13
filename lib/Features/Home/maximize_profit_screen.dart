import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../Service/Ads/banner_ads_service.dart';
import '../../Service/Ads/native_ads_service.dart';
import '../../Utility/blue_button.dart';
import '../../Utility/yellow_card.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_text.dart';
import '../../Utility/custom_appbar.dart';
import '../../Utility/image_const.dart';
import '../../Utility/bottom_navigation_controller.dart';
import '../Profile/refferal_screen.dart';
import 'home_controller.dart';

import 'profit_image_slider.dart';

class MaximizeProfitScreen extends StatefulWidget {
  const MaximizeProfitScreen({super.key});

  @override
  State<MaximizeProfitScreen> createState() => _MaximizeProfitScreenState();
}

class _MaximizeProfitScreenState extends State<MaximizeProfitScreen> {
  final HomeController homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColor.background,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: CustomAppBar(
                title: "",
                fontSize: 24,
              ),
            ),
            // Main Title
            const Center(
              child: CommonText.h1(
                "Maximize Estimated Profit",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: CommonText.body(
                  "Maximize your estimated mining performance by upgrading your miner and using available features wisely.",
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const ProfitImageSlider(),
                    const SizedBox(height: 20),
                    const Center(child: AppNativeAd()),
                    const SizedBox(height: 24),
                    
                    // Tips 1
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CommonText.body(
                          "Tips 1. ",
                          style: TextStyle(
                            color: CommonColor.orange,
                            fontWeight: FontWeight.normal,
                            fontSize: 15,
                          ),
                        ),
                        Expanded(
                          child: CommonText.body(
                            "Upgrade Your Mining Speed",
                            style: TextStyle(
                              color: Colors.grey.shade100,
                              fontWeight: FontWeight.normal,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    CommonText.body(
                      "Purchase additional Hash Rate (GH/s, TH/s, PH/s) to increase your estimated mining rewards. Higher Speed = Higher Estimated Earnings",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    BlueButton(
                      text: "Buy Now",
                      width: 100,
                      height: 38,
                      onPressed: () {
                        Get.find<NavigationController>().changeIndex(1);
                        Get.back();
                      },
                    ),
                    const SizedBox(height: 24),

                    // Tips 2
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CommonText.body(
                          "Tips 2. ",
                          style: TextStyle(
                            color: CommonColor.orange,
                            fontWeight: FontWeight.normal,
                            fontSize: 15,
                          ),
                        ),
                        Expanded(
                          child: CommonText.body(
                            "Use Mining Boost",
                            style: TextStyle(
                              color: Colors.grey.shade100,
                              fontWeight: FontWeight.normal,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    CommonText.body(
                      "Activate temporary boosts to increase your mining performance.",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: CommonColor.greyCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            ImageConst.playButton,
                            width: 28,
                            height: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CommonText.body(
                                  "up to 5X Boost",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                CommonText.small(
                                  "Watch ads & earn 5 min extra power",
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Obx(() {
                            final isBoosting = homeController.isBoosting.value;
                            return YellowCard(
                              width: 85,
                              height: 36,
                              borderRadius: 8,
                              onTap: isBoosting ? () {} : () => homeController.triggerBoost(),
                              child: Text(
                                isBoosting ? "Loading..." : "Boost",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tips 3
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CommonText.body(
                          "Tips 3. ",
                          style: TextStyle(
                            color: CommonColor.orange,
                            fontWeight: FontWeight.normal,
                            fontSize: 15,
                          ),
                        ),
                        Expanded(
                          child: CommonText.body(
                            "Invite Friends",
                            style: TextStyle(
                              color: Colors.grey.shade100,
                              fontWeight: FontWeight.normal,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    CommonText.body(
                      "Invite friends and receive bonus rewards and additional mining benefits.",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    YellowCard(
                      width: double.infinity,
                      height: 48,
                      borderRadius: 24,
                      onTap: () {
                        Get.to(
                          () => const ReferralScreenView(),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                      child: const Text(
                        "Invite friends",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const CommonText.body(
                      "Important Notice",
                      style: TextStyle(
                        color: CommonColor.orange,
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CommonText.body(
                      "This app is a virtual crypto mining simulator.\n\n"
                      "No real cryptocurrency is mined.\n"
                      "All mining speeds, rewards, and earnings are estimated and simulated.\n"
                      "Premium purchases increase virtual mining speed within the app only.\n"
                      "Purchasing a Premium Plan does not guarantee real financial returns or cryptocurrency payouts.",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Banner Ad - full width
            const AppBanner(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

