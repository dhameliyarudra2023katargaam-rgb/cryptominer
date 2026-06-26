import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utility/black_card.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_text.dart';
import '../../Utility/custom_appbar.dart';
import 'store_screen_controller.dart';
import 'store_model.dart';

class MyMinerScreen extends StatefulWidget {
  const MyMinerScreen({super.key});

  @override
  State<MyMinerScreen> createState() => _MyMinerScreenState();
}

class _MyMinerScreenState extends State<MyMinerScreen> {
  bool isPaidSelected = true;
  final StoreController controller = Get.find<StoreController>();

  @override
  void initState() {
    super.initState();
    // Refresh subscription details on view entry after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCurrentSubscription();
      controller.fetchSubscriptionPlans();
    });
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return "N/A";
    try {
      final DateTime parsed = DateTime.parse(dateStr).toLocal();
      final List<String> months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
      ];
      final String month = months[parsed.month - 1];

      String suffix = "th";
      final int day = parsed.day;
      if (day == 1 || day == 21 || day == 31) {
        suffix = "st";
      } else if (day == 2 || day == 22) {
        suffix = "nd";
      } else if (day == 3 || day == 23) {
        suffix = "rd";
      }

      return "$day$suffix $month, ${parsed.year}";
    } catch (e) {
      return dateStr;
    }
  }

  void _showPurchaseDialog(BuildContext context, SubscriptionPlan plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CommonColor.greyCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const CommonText.h2(
          "Confirm Purchase",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText.body(
              "Plan: ${plan.displayName}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 6),
            CommonText.body(
              "Speed: ${plan.miningSpeed.toStringAsFixed(0)} GH/s",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 6),
            CommonText.h3(
              "Price: ₹${plan.price.toStringAsFixed(2)}",
              style: const TextStyle(color: CommonColor.orange),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Obx(() => controller.isPurchasing.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: CommonColor.orange,
                  ),
                )
              : TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    controller.purchasePlan(plan);
                  },
                  child: const Text(
                    "Buy Now",
                    style: TextStyle(
                      color: CommonColor.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColor.background,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: "My Miner",
              fontSize: 26,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Toggle Tab Selector ---
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isPaidSelected = true),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isPaidSelected ? CommonColor.orange : Colors.transparent,
                                  borderRadius: BorderRadius.circular(21),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Paid",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: isPaidSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isPaidSelected = false),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !isPaidSelected ? CommonColor.orange : Colors.transparent,
                                  borderRadius: BorderRadius.circular(21),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Free",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: !isPaidSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- Tab Content based on selection ---
                    if (isPaidSelected) ...[
                      // --- Current Active Paid Plan Card ---
                      Obx(() {
                        final sub = controller.currentSubscription.value;
                        final isLoading = controller.isLoadingCurrent.value;

                        if (isLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: CircularProgressIndicator(color: CommonColor.orange),
                            ),
                          );
                        }

                        String speedText = "100 Th/s";
                        String profitText = "37.31%";
                        String expiryText = "25th Jun, 2026";
                        String actionText = "Buy Now";
                        VoidCallback onActionTap = () {
                          // Open purchase dialog for first plan as default action
                          if (controller.plans.isNotEmpty) {
                            _showPurchaseDialog(context, controller.plans.first);
                          } else {
                            Get.snackbar("Notice", "Please choose a plan from the list below.");
                          }
                        };

                        if (sub != null) {
                          speedText = "${sub.miningSpeed.toStringAsFixed(0)} Th/s";
                          final matchedPlan = controller.plans.firstWhereOrNull((p) => p.name == sub.planName);
                          profitText = "${matchedPlan?.aprPercent.toStringAsFixed(2) ?? "37.31"}%";
                          expiryText = _formatDate(sub.endDate);
                          actionText = "Renew";
                          onActionTap = () {
                            if (matchedPlan != null) {
                              _showPurchaseDialog(context, matchedPlan);
                            } else {
                              Get.snackbar("Notice", "Cannot determine plan template for renewal.");
                            }
                          };
                        }

                        return GradientBorderContainer(
                          width: double.infinity,
                          height: 155,
                          borderRadius: 16,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Speed CPU Power",
                                        style: TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        speedText,
                                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Estimate Profit",
                                        style: TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        profitText,
                                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.white12, height: 1),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Expires on",
                                        style: TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        expiryText,
                                        style: const TextStyle(color: CommonColor.orange, fontSize: 14, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: onActionTap,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: CommonColor.orange,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        actionText,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 32),

                      // --- Suggest Miner Title ---
                      const CommonText.h1(
                        "Suggest Miner",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- Suggest Miner Grid ---
                      Obx(() {
                        if (controller.isLoadingPlans.value) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.0),
                              child: CircularProgressIndicator(color: CommonColor.orange),
                            ),
                          );
                        }

                        final plans = controller.plans;
                        if (plans.isEmpty) {
                          return const Center(
                            child: CommonText.body(
                              "No plans available",
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: plans.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.85,
                          ),
                          itemBuilder: (context, index) {
                            final plan = plans[index];
                            return SuggestMinerCard(
                              plan: plan,
                              onTap: () => _showPurchaseDialog(context, plan),
                            );
                          },
                        );
                      }),
                    ] else ...[
                      // --- Free Tab Two Cards ---
                      // Card 1: Base Free Miner
                      GradientBorderContainer(
                        width: double.infinity,
                        height: 155,
                        borderRadius: 16,
                        padding: const EdgeInsets.all(16),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Speed CPU Power",
                                      style: TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "100 Th/s",
                                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Estimate Profit",
                                      style: TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "+15 %",
                                      style: TextStyle(color: CommonColor.orange, fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Divider(color: Colors.white12, height: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Expires on",
                                      style: TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "Free",
                                      style: TextStyle(color: CommonColor.orange, fontSize: 14, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 48), // Spacer to keep layout balanced
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Card 2: Boost Free Miner
                      GradientBorderContainer(
                        width: double.infinity,
                        height: 155,
                        borderRadius: 16,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Speed CPU Power",
                                      style: TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "10 Th/s",
                                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Estimate Profit",
                                      style: TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "+1.5 %",
                                      style: TextStyle(color: CommonColor.orange, fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white12, height: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Expires on",
                                      style: TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "5 min",
                                      style: TextStyle(color: CommonColor.orange, fontSize: 14, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Get.snackbar(
                                      "Boost Activated 🚀",
                                      "Your free miner speed has been boosted by +10 Th/s!",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: CommonColor.blue,
                                      colorText: Colors.white,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: CommonColor.blue,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Text(
                                      "Boost Again",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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

class SuggestMinerCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final VoidCallback onTap;

  const SuggestMinerCard({
    super.key,
    required this.plan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GradientBorderContainer(
      borderRadius: 16,
      strokeWidth: 1.2,
      backgroundColor: CommonColor.greyCard,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${plan.miningSpeed.toStringAsFixed(0)} Th/s",
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Estimate Profit",
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                "+${plan.aprPercent.toStringAsFixed(1)}%",
                style: const TextStyle(color: CommonColor.orange, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Expires",
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              const SizedBox(height: 2),
              const Text(
                "90 Days",
                style: TextStyle(color: CommonColor.orange, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: CommonColor.orange,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                "₹${plan.price.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
