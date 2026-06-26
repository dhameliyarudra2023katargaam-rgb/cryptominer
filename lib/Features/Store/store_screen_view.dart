import 'package:cryptominer/Features/Store/store_screen_controller.dart';
import 'package:cryptominer/Features/Store/spped_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utility/black_card.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_next_arrow_icon.dart';
import '../../Utility/common_text.dart';
import '../../Utility/custom_appbar.dart';
import '../../Utility/font_style.dart';
import '../../Utility/yellow_card.dart';
import 'store_model.dart';
import 'my_miner_screen.dart';

class StoreScreenView extends StatelessWidget {
  const StoreScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    // Register controller if not already registered
    final StoreController controller = Get.put(StoreController());

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomAppBar(
            title: "Store",
            fontSize: 26,
            leading: SizedBox(width: 48),
            actions: [SizedBox(width: 48)],
          ),
          const SizedBox(height: 24),

          // ── Active Mining Power Card ──────────────────────────────────────
          Obx(() {
            final sub = controller.currentSubscription.value;
            final isLoading = controller.isLoadingCurrent.value;

            return Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  Get.to(
                    () => const MyMinerScreen(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 300),
                  );
                },
                child: GradientBorderContainer(
                  width: 371,
                  height: 80,
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText.small(
                                "Active Mining Power",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              isLoading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: CommonColor.orange,
                                      ),
                                    )
                                  : sub == null
                                      ? CommonText.h3(
                                          "No Active Plan",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                        )
                                      : RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "${sub.planDisplayName} • ",
                                                style: CommonFontStyles.heading3
                                                    .copyWith(fontSize: 16),
                                              ),
                                              TextSpan(
                                                text:
                                                    "${sub.miningSpeed.toStringAsFixed(0)} GH/s",
                                                style: CommonFontStyles.heading3
                                                    .copyWith(
                                                  color: CommonColor.orange,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 6.0),
                        child: NextArrowIcon(size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),

          // ── Ads Banner ───────────────────────────────────────────────────
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 347,
              height: 50,
              decoration: BoxDecoration(
                color: CommonColor.darkRed.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CommonText.small(
                  "ADS BANNER",
                  style: const TextStyle(
                    color: CommonColor.red,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Speed Section Title ───────────────────────────────────────────
          const CommonText.h1("Speed"),
          const SizedBox(height: 16),

          // ── Speed Plan Cards (dynamic from API) ───────────────────────────
          Obx(() {
            if (controller.isLoadingPlans.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(color: CommonColor.orange),
                ),
              );
            }

            final List<SubscriptionPlan> planList = controller.plans;

            if (planList.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CommonText.body(
                    "No plans available",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            // Build rows of 2 cards each
            final List<Widget> rows = [];
            for (int i = 0; i < planList.length; i += 2) {
              final plan1 = planList[i];
              final plan2 = (i + 1 < planList.length) ? planList[i + 1] : null;

              rows.add(
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(() => SpeedCard(
                          speedText:
                              "${plan1.miningSpeed.toStringAsFixed(0)} GH/s",
                          aprValue: "${plan1.aprPercent.toStringAsFixed(2)}%",
                          freeCpuValue:
                              "+${plan1.freeCpuPercent.toStringAsFixed(1)}%",
                          price: "₹${plan1.price.toStringAsFixed(2)}",
                          isSelected:
                              controller.selectedPlanIndex.value == i,
                          discountText: plan1.discountText,
                          onTap: () {
                            controller.selectPlan(i);
                            _showPurchaseDialog(context, controller, plan1);
                          },
                        )),
                    const SizedBox(width: 14),
                    plan2 != null
                        ? Obx(() => SpeedCard(
                              speedText:
                                  "${plan2.miningSpeed.toStringAsFixed(0)} GH/s",
                              aprValue:
                                  "${plan2.aprPercent.toStringAsFixed(2)}%",
                              freeCpuValue:
                                  "+${plan2.freeCpuPercent.toStringAsFixed(1)}%",
                              price: "₹${plan2.price.toStringAsFixed(2)}",
                              isSelected:
                                  controller.selectedPlanIndex.value == i + 1,
                              discountText: plan2.discountText,
                              onTap: () {
                                controller.selectPlan(i + 1);
                                _showPurchaseDialog(
                                    context, controller, plan2);
                              },
                            ))
                        : const Expanded(child: SizedBox()),
                  ],
                ),
              );

              if (i + 2 < planList.length) {
                rows.add(const SizedBox(height: 14));
              }
            }

            return Column(children: rows);
          }),
          const SizedBox(height: 40),

          // ── Boost Button ─────────────────────────────────────────────────
          YellowCard(
            onTap: () {
              // Boost: ad-token → show rewarded ad → start mining
              // This flow is handled in the Home/Mining controller
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.smart_display_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                CommonText.h3(
                  "Boost ( 5Min )",
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  // ── Purchase Confirmation Dialog ────────────────────────────────────────────
  void _showPurchaseDialog(
    BuildContext context,
    StoreController controller,
    SubscriptionPlan plan,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CommonColor.greyCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: CommonText.h2(
          "Confirm Purchase",
          style: const TextStyle(color: Colors.white),
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
}