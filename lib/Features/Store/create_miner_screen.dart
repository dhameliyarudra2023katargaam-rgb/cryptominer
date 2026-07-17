import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utility/app_snackbar.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_text.dart';
import '../../Utility/custom_appbar.dart';
import 'create_miner_controller.dart';
import 'create_miner_model.dart';

class CreateMinerScreen extends StatelessWidget {
  const CreateMinerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateMinerController controller = Get.put(CreateMinerController());

    return Scaffold(
      backgroundColor: CommonColor.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar (same pattern as other screens) ─────────────────────
            const CustomAppBar(title: "Create Minor", fontSize: 26),

            // ── Breadcrumb ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 2, bottom: 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CommonText.small(
                  "Purchage / Create Minor",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            // ── Scrollable Content ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                child: Obx(() {
                  final isLoading = controller.isLoadingPlans.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Select CPU ────────────────────────────────────────
                      const CommonText.body(
                        "Select CPU",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _CpuChipRow(controller: controller),
                      const SizedBox(height: 24),

                      // ── Estimate Profit ───────────────────────────────────
                      const CommonText.body(
                        "Estimate Profit",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _EstimateProfitCard(controller: controller),
                      const SizedBox(height: 24),

                      // ── Rental Duration ───────────────────────────────────
                      const CommonText.body(
                        "Rental Duration",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(
                              color: CommonColor.orange,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      else if (controller.plans.isEmpty)
                        _EmptyPlansCard()
                      else
                        _RentalDurationList(controller: controller),

                      const SizedBox(height: 20),

                      // ── Important Disclaimer ──────────────────────────────
                      _DisclaimerText(),
                      const SizedBox(height: 16),

                    ],
                  );
                }),
              ),
            ),

            // ── Bottom: Subscribe Button + Guidelines ──────────────────────
            _BottomSection(controller: controller),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CPU Chip Row Widget - 10 Th/s | 20 Th/s | 30 Th/s
// ─────────────────────────────────────────────────────────────────────────────
class _CpuChipRow extends StatelessWidget {
  final CreateMinerController controller;
  const _CpuChipRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.cpuOptions.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 4.0),
          child: CommonText.body(
            "No CPU types available right now.",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(controller.cpuOptions.length, (i) {
            final option = controller.cpuOptions[i];
            final isSelected = controller.selectedCpuIndex.value == i;

            return Padding(
              padding: EdgeInsets.only(right: i < controller.cpuOptions.length - 1 ? 12 : 0),
              child: GestureDetector(
                onTap: () => controller.selectCpu(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.transparent
                        : CommonColor.greyCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? CommonColor.orange
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: CommonText.body(
                    option.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected
                          ? FontWeight.normal
                          : FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estimate Profit Card - "+ 30.1 %"
// ─────────────────────────────────────────────────────────────────────────────
class _EstimateProfitCard extends StatelessWidget {
  final CreateMinerController controller;
  const _EstimateProfitCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: CommonColor.greyCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: CommonText.body(
          controller.estimateProfitLabel,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rental Duration List - Plan cards
// ─────────────────────────────────────────────────────────────────────────────
class _RentalDurationList extends StatelessWidget {
  final CreateMinerController controller;
  const _RentalDurationList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: List.generate(controller.filteredPlans.length, (i) {
          final plan = controller.filteredPlans[i];
          final isSelected = controller.selectedPlanIndex.value == i;

          return _PlanCard(
            plan: plan,
            isSelected: isSelected,
            onTap: () => controller.selectPlan(i),
          );
        }),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual Plan Card
// ─────────────────────────────────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  final CreateMinerPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.transparent : CommonColor.greyCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? CommonColor.blue : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: CommonText.body(
                  plan.priceLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),

              // "Popular" badge - as shown in image
              if (plan.isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: CommonColor.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const CommonText.small(
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty Plans Card (when API returns empty)
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyPlansCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CommonColor.greyCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CommonText.body(
          "No plans available right now.",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Disclaimer / Important Note text (exact match from image)
// ─────────────────────────────────────────────────────────────────────────────
class _DisclaimerText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const CommonText.small(
      "Important: Speed Boost Subscription only increases estimated mining speed within the app. It does not provide real cryptocurrency, real cash rewards, real earnings, real withdrawals, or investment returns. All mining results shown are simulated and for entertainment purposes only.",
      style: TextStyle(
        color: Colors.grey,
        fontSize: 12,
        height: 1.6,
      ),
      textAlign: TextAlign.center,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Section - Subscribe Button + Purchases Guidelines
// ─────────────────────────────────────────────────────────────────────────────
class _BottomSection extends StatelessWidget {
  final CreateMinerController controller;
  const _BottomSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CommonColor.background,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Restore Purchases ─────────────────────────────────
          Center(
            child: GestureDetector(
              onTap: () {
                Get.snackbar(
                  "Restore Purchases",
                  "Checking for previous purchases...",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: CommonColor.greyCard,
                  colorText: Colors.white,
                );
              },
              child: const CommonText.body(
                "Restore Purchases",
                style: TextStyle(
                  color: CommonColor.blue,
                  fontSize: 14,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Subscribe Button (Obx for reactive isPurchasing & plans) ───────
          Obx(() => SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: (controller.isPurchasing.value || controller.plans.isEmpty)
                  ? null
                  : () => controller.subscribePlan(),
              style: ElevatedButton.styleFrom(
                backgroundColor: CommonColor.blue,
                disabledBackgroundColor: CommonColor.blue.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: controller.isPurchasing.value
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Obx(() => CommonText.body(
                      controller.subscribeBtnLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    )),
            ),
          )),
          const SizedBox(height: 10),

          // ── Purchases Guidelines ──────────────────────────────────────────
          GestureDetector(
            onTap: () {
              AppSnackbar.notice("All purchases are final and non-refundable.", title: "Purchases Guidelines");
            },
            child: const CommonText.small(
              "Purchases Guidelines",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
