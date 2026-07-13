import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Service/Ads/native_ads_service.dart';
import '../../Utility/app_snackbar.dart';
import '../../Utility/yellow_card.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_text.dart';
import '../../Utility/custom_appbar.dart';
import '../Home/home_controller.dart';

class PlanDetailsScreen extends StatefulWidget {
  final String speed;
  final String profit;
  final String speedUpTo;
  final String minerCount;

  const PlanDetailsScreen({
    super.key,
    required this.speed,
    required this.profit,
    this.speedUpTo = "2x",
    this.minerCount = "10",
  });

  @override
  State<PlanDetailsScreen> createState() => _PlanDetailsScreenState();
}

class _PlanDetailsScreenState extends State<PlanDetailsScreen> {
  final HomeController homeController = Get.find<HomeController>();
  int _selectedDurationIndex = 1; // Default is the 3 Month option (index 1)

  final List<Map<String, dynamic>> _rentalOptions = [
    {
      "price": 720,
      "duration": "1 Month",
      "popular": false,
    },
    {
      "price": 2050,
      "duration": "3 Month",
      "popular": true,
    },
    {
      "price": 3450,
      "duration": "6 Month",
      "popular": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final selectedOption = _rentalOptions[_selectedDurationIndex];
    final selectedPrice = selectedOption["price"];
    final selectedDurationText = _selectedDurationIndex == 0
        ? "1 Mon"
        : _selectedDurationIndex == 1
            ? "3 Mon"
            : "6 Mon";

    return Scaffold(
      backgroundColor: CommonColor.background,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: CustomAppBar(
                title: "Plan Details",
                fontSize: 24,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Details Card ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: CommonColor.greyCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Speed CPU Power",
                                      style: TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    CommonText.h2(
                                      widget.speed,
                                      style: const TextStyle(fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Estimate Profit",
                                      style: TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    CommonText.h2(
                                      widget.profit,
                                      style: const TextStyle(fontWeight: FontWeight.normal, color: CommonColor.orange),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Speed Up to",
                                      style: TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    CommonText.h2(
                                      widget.speedUpTo,
                                      style: const TextStyle(fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Miner Count",
                                      style: TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    CommonText.h2(
                                      widget.minerCount,
                                      style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Ad Banner ---
                    const Center(child: AppNativeAd()),
                    const SizedBox(height: 24),

                    // --- Rental Duration Title ---
                    const CommonText.h2(
                      "Rental Duration",
                      style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
                    ),
                    const SizedBox(height: 16),

                    // --- Rental Duration Selector ---
                    Column(
                      children: List.generate(_rentalOptions.length, (index) {
                        final option = _rentalOptions[index];
                        final isSelected = _selectedDurationIndex == index;
                        final isPopular = option["popular"] as bool;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDurationIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: CommonColor.greyCard,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? CommonColor.blue : Colors.transparent,
                                width: 2.0,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CommonText.body(
                                  "₹ ${option["price"]}/ ${option["duration"]}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                if (isPopular)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: CommonColor.blue,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      "Popular",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // --- Watch Ads & Boost Button ---
                    Obx(() {
                      final isBoosting = homeController.isBoosting.value;
                      return YellowCard(
                        width: double.infinity,
                        height: 52,
                        borderRadius: 26,
                        onTap: isBoosting ? () {} : () => homeController.triggerBoost(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_circle_fill, color: Colors.white, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              isBoosting ? "Loading..." : "Watch Ads & Boost (5 Min)",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),

                    // --- Restore Purchases ---
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          AppSnackbar.success("Purchases restored successfully!");
                        },
                        child: const Text(
                          "Restore Purchases",
                          style: TextStyle(
                            color: CommonColor.blue,
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Subscribe Button ---
                    GestureDetector(
                      onTap: () {
                        AppSnackbar.success(
                          "Subscription successful!",
                          title: "Success 🎉",
                        );
                        Get.back();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          color: CommonColor.blue,
                          borderRadius: BorderRadius.circular(27),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Subscribe ₹ $selectedPrice / $selectedDurationText",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Notice Footnote ---
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          "Important Notice: Speed Boost affects in-app estimated mining only. No real crypto, cash, or withdrawals.",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
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
