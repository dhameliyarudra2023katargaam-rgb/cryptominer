import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utility/app_snackbar.dart';
import '../../Utility/black_card.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_text.dart';
import '../../Utility/custom_appbar.dart';
import '../../Service/Ads/banner_ads_service.dart';
import 'store_screen_controller.dart';
import 'store_model.dart';
import 'plan_details_screen.dart';
import '../Home/home_controller.dart';

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
      controller.fetchFreeMiningData();
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
                      fontWeight: FontWeight.normal,
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
              fontSize: 24,
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
                                    fontWeight: isPaidSelected ? FontWeight.normal : FontWeight.normal,
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
                                    fontWeight: !isPaidSelected ? FontWeight.normal : FontWeight.normal,
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

                        if (sub == null) {
                          return Container(
                            width: double.infinity,
                            height: 155,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white12),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.info_outline, color: Colors.grey, size: 32),
                                const SizedBox(height: 12),
                                const Text(
                                  "No Active Plan",
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.normal),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Choose a plan from below to get started",
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          );
                        }

                        // We have an active subscription
                        String speedText = "${sub.miningSpeed.toStringAsFixed(0)} Th/s";
                        final matchedPlan = controller.plans.firstWhereOrNull((p) => p.name == sub.planName);
                        String profitText = "${matchedPlan?.aprPercent.toStringAsFixed(2) ?? "0.00"}%";
                        String expiryText = _formatDate(sub.endDate);
                        String actionText = "Renew";
                        VoidCallback onActionTap = () {
                          if (matchedPlan != null) {
                            _showPurchaseDialog(context, matchedPlan);
                          } else {
                            AppSnackbar.notice("Cannot determine plan template for renewal.");
                          }
                        };

                        return GestureDetector(
                          onTap: () {
                            Get.to(
                              () => PlanDetailsScreen(
                                speed: speedText,
                                profit: profitText,
                              ),
                              transition: Transition.rightToLeft,
                              duration: const Duration(milliseconds: 300),
                            );
                          },
                          child: GradientBorderContainer(
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
                                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.normal),
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
                                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.normal),
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
                                          style: const TextStyle(color: CommonColor.orange, fontSize: 14, fontWeight: FontWeight.normal),
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
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 13),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 32),

                      // --- Suggest Miner Title ---
                      const CommonText.h1(
                        "Suggest Miner",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
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
                      // --- Free Tab Active Plan ---
                      Obx(() {
                        final homeCtrl = Get.find<HomeController>();
                        final speed = homeCtrl.effectiveFreeMiningSpeed.toStringAsFixed(1);
                        final isBoosting = homeCtrl.isBoosting.value;
                        final boostTime = homeCtrl.boostRemainingSeconds.value;
                        
                        String expiryText = "Unlimited";
                        if (isBoosting && boostTime > 0) {
                          int minutes = boostTime ~/ 60;
                          int seconds = boostTime % 60;
                          expiryText = "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
                        }

                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.to(
                                  () => PlanDetailsScreen(
                                    speed: "$speed GH/s",
                                    profit: "Free",
                                  ),
                                  transition: Transition.rightToLeft,
                                  duration: const Duration(milliseconds: 300),
                                );
                              },
                              child: GradientBorderContainer(
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
                                              "$speed GH/s",
                                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.normal),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                             // 2 => 1st changes
                                              //  "Plan Type",
                                              "Estimate Profit",
                                              style: TextStyle(color: Colors.grey, fontSize: 13),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              // 2 => 1st changes
                                              //  isBoosting ? "Boosted" : "Free Basic",
                                              "+${homeCtrl.miningConfig['freeApr'] ?? '1.5'}%",
                                              style: const TextStyle(color: CommonColor.orange, fontSize: 18, fontWeight: FontWeight.normal),
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
                                            Text(
                                              isBoosting ? "Boost Expires in" : "Expires on",
                                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              expiryText,
                                              style: const TextStyle(color: CommonColor.orange, fontSize: 14, fontWeight: FontWeight.normal),
                                            ),
                                          ],
                                        ),
                                        if (!isBoosting)
                                          GestureDetector(
                                            onTap: () {
                                              homeCtrl.triggerBoost();
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: CommonColor.blue,
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: const Text(
                                                "Boost Speed",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          )
                                        else
                                          const Text(
                                            "Active",
                                            style: TextStyle(
                                              color: Colors.greenAccent,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
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
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.normal),
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
                style: const TextStyle(color: CommonColor.orange, fontSize: 13, fontWeight: FontWeight.normal),
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
                style: TextStyle(color: CommonColor.orange, fontSize: 13, fontWeight: FontWeight.normal),
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
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.normal),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
