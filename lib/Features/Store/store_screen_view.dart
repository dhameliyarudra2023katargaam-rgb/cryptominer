import 'package:cryptominer/Features/Store/create_miner_screen.dart';
import 'package:cryptominer/Features/Store/spped_card.dart';
import 'package:cryptominer/Features/Store/store_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Service/Ads/native_ads_service.dart';
import '../../Utility/app_custom_dialog.dart';

import '../../Utility/black_card.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_next_arrow_icon.dart';
import '../../Utility/common_text.dart';
import '../../Utility/custom_appbar.dart';
import '../../Utility/font_style.dart';
import 'my_miner_screen.dart';
// import '../../Utility/yellow_card.dart'; // Boost button commented out
import 'package:cryptominer/Features/Store/store_model.dart';

class StoreScreenView extends StatelessWidget {
  const StoreScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    // Register controller if not already registered
    final StoreController controller = Get.put(StoreController());

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 0, left: 20, right: 20),
          child: CustomAppBar(
            title: "Store",
            fontSize: 26,
            leading: SizedBox(width: 48),
            actions: [SizedBox(width: 48)],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

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
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "${sub.planDisplayName} • ",
                                                style: CommonFontStyles.heading3
                                                    .copyWith(fontSize: 16),
                                              ),
                                              TextSpan(
                                                text: sub.miningSpeed >= 1000
                                                    ? "${(sub.miningSpeed / 1000).toStringAsFixed(0)} TH/s"
                                                    : "${sub.miningSpeed.toStringAsFixed(0)} GH/s",
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
          const SizedBox(height: 16),

          // ── Ads Banner ───────────────────────────────────────────────────
          const Center(child: AppNativeAd()),
          const SizedBox(height: 18),

          // ── Speed Section Title ───────────────────────────────────────────
          Row(
            children: [
              const CommonText.h2(
                "Speed- Hash Rate",
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  AppCustomDialog.show(
                    context: context,
                    title: "Mining Speed",
                    message:
                        "Estimated mining speed is dynamic and may increase or decrease based on network conditions, device performance, and server activity. This is normal app behavior.",
                  );
                },
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
            ],
          ),
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
                          speedText: plan1.miningSpeed >= 1000
                              ? "${(plan1.miningSpeed / 1000).toStringAsFixed(0)} TH/s"
                              : "${plan1.miningSpeed.toStringAsFixed(0)} GH/s",
                          aprValue: "${plan1.aprPercent.toStringAsFixed(2)}%",
                          freeCpuValue:
                              "+${plan1.freeCpuPercent.toStringAsFixed(1)}%",
                          price: "₹${plan1.price.toStringAsFixed(2)}",
                          isSelected:
                              controller.selectedPlanIndex.value == i,
                          discountText: plan1.discountText,
                           onTap: () {
                            controller.selectPlan(i);
                            Get.to(
                              () => const CreateMinerScreen(),
                              arguments: {
                                'speed': plan1.miningSpeed,
                                'id': plan1.id,
                              },
                              transition: Transition.rightToLeft,
                              duration: const Duration(milliseconds: 300),
                            )?.then((_) {
                              controller.selectPlan(-1);
                            });
                          },
                        )),
                    const SizedBox(width: 14),
                    plan2 != null
                        ? Obx(() => SpeedCard(
                              speedText: plan2.miningSpeed >= 1000
                                  ? "${(plan2.miningSpeed / 1000).toStringAsFixed(0)} TH/s"
                                  : "${plan2.miningSpeed.toStringAsFixed(0)} GH/s",
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
                                  Get.to(
                                    () => const CreateMinerScreen(),
                                    arguments: {
                                      'speed': plan2.miningSpeed,
                                      'id': plan2.id,
                                    },
                                    transition: Transition.rightToLeft,
                                    duration: const Duration(milliseconds: 300),
                                  )?.then((_) {
                                    controller.selectPlan(-1);
                                  });
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
          const SizedBox(height: 24),

          // ── Boost Button (commented out - moved to Home screen) ───────────
          // YellowCard(
          //   onTap: () {
          //     // Boost: ad-token → show rewarded ad → start mining
          //     // This flow is handled in the Home/Mining controller
          //   },
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       const Icon(Icons.smart_display_rounded, color: Colors.white, size: 20),
          //       const SizedBox(width: 8),
          //       CommonText.h3("Boost ( 5Min )", style: const TextStyle(fontSize: 18)),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 14),

          // ── Purchase Button (opens Create Minor screen) ───────────────────
          Obx(() {
            final int idx = controller.selectedPlanIndex.value;
            if (idx == -1) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (idx >= 0 && idx < controller.plans.length) {
                        Get.to(
                          () => const CreateMinerScreen(),
                          arguments: {
                            'speed': controller.plans[idx].miningSpeed,
                            'id': controller.plans[idx].id,
                          },
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 300),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CommonColor.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Purchase",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          }),
              ],
            ),
          ),
        ],
      ),
      ),
      ),
      ],
    );
  }


}
