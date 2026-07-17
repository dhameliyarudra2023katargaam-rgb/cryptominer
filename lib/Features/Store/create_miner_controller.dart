import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Repo/create_miner_repo.dart';
import '../../Utility/app_snackbar.dart';
import 'create_miner_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CreateMinerController
// Image match:
//   1. Select CPU  → 10 Th/s, 20 Th/s, 30 Th/s (chips)
//   2. Estimate Profit → selected plan's profit %
//   3. Rental Duration → plans list (1 Month, 3 Month, 6 Month)
//   4. Subscribe button → purchase API call
// ─────────────────────────────────────────────────────────────────────────────

class CreateMinerController extends GetxController {
  // ─── CPU Speed Options (Dynamic from API) ────────
  final RxList<CpuSpeedOption> cpuOptions = <CpuSpeedOption>[].obs;

  /// Currently selected CPU chip index
  final RxInt selectedCpuIndex = 0.obs;

  // ─── Rental Duration Plans ────────────────────────────────────────────────
  final RxList<CreateMinerPlan> plans = <CreateMinerPlan>[].obs;

  /// Currently selected plan index
  final RxInt selectedPlanIndex = 1.obs; // default: 3 Month (Popular)

  // ─── Loading & Purchasing flags ───────────────────────────────────────────
  final RxBool isLoadingPlans = false.obs;
  final RxBool isPurchasing = false.obs;

  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
  }

  // ─── Filtered Plans based on Selected CPU ─────────────────────────────────
  List<CreateMinerPlan> get filteredPlans {
    if (cpuOptions.isEmpty || plans.isEmpty) return [];
    final selectedSpeed = cpuOptions[selectedCpuIndex.value].speedThs;
    return plans.where((p) => p.miningSpeedThs == selectedSpeed).toList();
  }

  // ─── Selected Plan getter ─────────────────────────────────────────────────
  CreateMinerPlan? get selectedPlan {
    final filtered = filteredPlans;
    if (filtered.isEmpty) return null;
    
    // Ensure selected index is valid for filtered list
    final idx = selectedPlanIndex.value;
    if (idx < 0 || idx >= filtered.length) {
      // If out of bounds (e.g. after CPU change), select first available
      return filtered.first;
    }
    return filtered[idx];
  }

  /// Estimate Profit % display - selected plan's profit
  String get estimateProfitLabel {
    final plan = selectedPlan;
    if (plan == null) return '+ 0.0 %';
    return '+ ${plan.estimateProfitPercent.toStringAsFixed(1)} %';
  }

  /// Subscribe button label
  String get subscribeBtnLabel {
    final plan = selectedPlan;
    if (plan == null) return 'Subscribe';
    return plan.subscribeLabel;
  }

  // ─── CPU chip select ─────────────────────────────────────────────────────
  void selectCpu(int index) {
    selectedCpuIndex.value = index;
    // Reset selected plan index to 0 or popular when CPU changes
    final currentFiltered = filteredPlans;
    if (currentFiltered.isNotEmpty) {
      final popularIdx = currentFiltered.indexWhere((p) => p.isPopular);
      if (popularIdx != -1) {
        selectedPlanIndex.value = popularIdx;
      } else if (currentFiltered.length > 1) {
        selectedPlanIndex.value = 1; // Default to middle plan
      } else {
        selectedPlanIndex.value = 0;
      }
    }
    log("CreateMinerController: CPU selected → ${cpuOptions[index].label}");
  }

  // ─── Plan select ──────────────────────────────────────────────────────────
  void selectPlan(int index) {
    selectedPlanIndex.value = index;
    log("CreateMinerController: Plan selected → index $index");
  }

  // ─── GET /subscriptions/plans ─────────────────────────────────────────────
  Future<void> fetchPlans() async {
    try {
      isLoadingPlans.value = true;
      final response = await CreateMinerRepo.getSubscriptionPlans();

      List<dynamic> list = [];
      if (response != null && response['success'] == true) {
        final rawData = response['data'];
        if (rawData is List) {
          list = rawData;
        } else if (rawData is Map && rawData['plans'] is List) {
          list = rawData['plans'] as List;
        }
      }

      if (list.isNotEmpty) {
        plans.value = list
            .map((e) => CreateMinerPlan.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        // Fallback plans matching store_screen_view.dart data
        plans.value = [
          // 10 GH/s
          CreateMinerPlan(id: "plan_1_1", displayName: "10 GH/s Miner", price: 0.0, durationMonths: 1, miningSpeedThs: 10.0, estimateProfitPercent: 30.0),
          CreateMinerPlan(id: "plan_1_3", displayName: "10 GH/s Miner", price: 0.0, durationMonths: 3, miningSpeedThs: 10.0, estimateProfitPercent: 30.1, isPopular: true),
          CreateMinerPlan(id: "plan_1_6", displayName: "10 GH/s Miner", price: 0.0, durationMonths: 6, miningSpeedThs: 10.0, estimateProfitPercent: 30.2),

          // 20 GH/s
          CreateMinerPlan(id: "plan_2_1", displayName: "20 GH/s Miner", price: 0.0, durationMonths: 1, miningSpeedThs: 20.0, estimateProfitPercent: 30.0),
          CreateMinerPlan(id: "plan_2_3", displayName: "20 GH/s Miner", price: 0.0, durationMonths: 3, miningSpeedThs: 20.0, estimateProfitPercent: 30.1, isPopular: true),
          CreateMinerPlan(id: "plan_2_6", displayName: "20 GH/s Miner", price: 0.0, durationMonths: 6, miningSpeedThs: 20.0, estimateProfitPercent: 30.2),

          // 50 GH/s
          CreateMinerPlan(id: "plan_3_1", displayName: "50 GH/s Miner", price: 0.0, durationMonths: 1, miningSpeedThs: 50.0, estimateProfitPercent: 30.0),
          CreateMinerPlan(id: "plan_3_3", displayName: "50 GH/s Miner", price: 0.0, durationMonths: 3, miningSpeedThs: 50.0, estimateProfitPercent: 30.1, isPopular: true),
          CreateMinerPlan(id: "plan_3_6", displayName: "50 GH/s Miner", price: 0.0, durationMonths: 6, miningSpeedThs: 50.0, estimateProfitPercent: 30.2),

          // 100 GH/s
          CreateMinerPlan(id: "plan_4_1", displayName: "100 GH/s Miner", price: 0.0, durationMonths: 1, miningSpeedThs: 100.0, estimateProfitPercent: 30.0),
          CreateMinerPlan(id: "plan_4_3", displayName: "100 GH/s Miner", price: 0.0, durationMonths: 3, miningSpeedThs: 100.0, estimateProfitPercent: 30.1, isPopular: true),
          CreateMinerPlan(id: "plan_4_6", displayName: "100 GH/s Miner", price: 0.0, durationMonths: 6, miningSpeedThs: 100.0, estimateProfitPercent: 30.2),

          // 1000 GH/s (1 TH/s)
          CreateMinerPlan(id: "plan_5_1", displayName: "1000 GH/s Miner", price: 0.0, durationMonths: 1, miningSpeedThs: 1000.0, estimateProfitPercent: 30.0),
          CreateMinerPlan(id: "plan_5_3", displayName: "1000 GH/s Miner", price: 0.0, durationMonths: 3, miningSpeedThs: 1000.0, estimateProfitPercent: 30.1, isPopular: true),
          CreateMinerPlan(id: "plan_5_6", displayName: "1000 GH/s Miner", price: 0.0, durationMonths: 6, miningSpeedThs: 1000.0, estimateProfitPercent: 30.2),

          // 10000 GH/s (10 TH/s)
          CreateMinerPlan(id: "plan_6_1", displayName: "10000 GH/s Miner", price: 0.0, durationMonths: 1, miningSpeedThs: 10000.0, estimateProfitPercent: 30.0),
          CreateMinerPlan(id: "plan_6_3", displayName: "10000 GH/s Miner", price: 0.0, durationMonths: 3, miningSpeedThs: 10000.0, estimateProfitPercent: 30.1, isPopular: true),
          CreateMinerPlan(id: "plan_6_6", displayName: "10000 GH/s Miner", price: 0.0, durationMonths: 6, miningSpeedThs: 10000.0, estimateProfitPercent: 30.2),
        ];
      }

      // Populate dynamic CPU options based on unique speeds from plans
      final Set<double> uniqueSpeeds = plans.map((p) => p.miningSpeedThs).toSet();
      final List<double> sortedSpeeds = uniqueSpeeds.toList()..sort();
      
      cpuOptions.value = sortedSpeeds.map((s) {
        final label = s >= 1000 
            ? '${(s / 1000).toStringAsFixed(0)} TH/s' 
            : '${s.toStringAsFixed(0)} GH/s';
        return CpuSpeedOption(
          label: label,
          speedThs: s,
        );
      }).toList();

      final dynamic args = Get.arguments;
      double? initialSpeed;
      String? initialPlanId;

      if (args is Map) {
        initialSpeed = args['speed'] as double?;
        initialPlanId = args['id'] as String?;
      } else if (args is double) {
        initialSpeed = args;
      } else if (args is int) {
        initialSpeed = args.toDouble();
      }

      selectedCpuIndex.value = 0;
      if (initialSpeed != null) {
        final cpuIdx = cpuOptions.indexWhere((c) => c.speedThs == initialSpeed);
        if (cpuIdx != -1) {
          selectedCpuIndex.value = cpuIdx;
          
          // Try to match specific plan ID to select the exact duration
          if (initialPlanId != null) {
            final currentFiltered = plans.where((p) => p.miningSpeedThs == initialSpeed).toList();
            final matchIdx = currentFiltered.indexWhere((p) => p.id == initialPlanId);
            if (matchIdx != -1) {
              selectedPlanIndex.value = matchIdx;
            } else {
              _selectPopularPlanForCpu(cpuIdx, plans);
            }
          } else {
            _selectPopularPlanForCpu(cpuIdx, plans);
          }
        } else {
           _selectPopularOverall(plans);
        }
      } else {
        selectedCpuIndex.value = 0;
        if (cpuOptions.isNotEmpty) {
          _selectPopularPlanForCpu(0, plans);
        }
      }
      
      if (cpuOptions.isNotEmpty && initialPlanId == null) {
        selectCpu(selectedCpuIndex.value);
      }
      log("CreateMinerController: Loaded ${plans.length} plans");
    } catch (e) {
      log("CreateMinerController: fetchPlans error → $e");
    } finally {
      isLoadingPlans.value = false;
    }
  }

  void _selectPopularPlanForCpu(int cpuIdx, List<CreateMinerPlan> plans) {
    if (cpuIdx < 0 || cpuIdx >= cpuOptions.length) return;
    final speed = cpuOptions[cpuIdx].speedThs;
    final currentFiltered = plans.where((p) => p.miningSpeedThs == speed).toList();
    if (currentFiltered.isNotEmpty) {
      final popularIdx = currentFiltered.indexWhere((p) => p.isPopular);
      if (popularIdx != -1) {
        selectedPlanIndex.value = popularIdx;
      } else if (currentFiltered.length > 1) {
        selectedPlanIndex.value = 1; // Default to middle plan
      } else {
        selectedPlanIndex.value = 0;
      }
    }
  }

  void _selectPopularOverall(List<CreateMinerPlan> plans) {
    final popularPlanIdx = plans.indexWhere((p) => p.isPopular);
    if (popularPlanIdx != -1) {
      final popPlan = plans[popularPlanIdx];
      final popCpuIdx = cpuOptions.indexWhere((c) => c.speedThs == popPlan.miningSpeedThs);
      if (popCpuIdx != -1) {
        selectedCpuIndex.value = popCpuIdx;
      }
    }
  }

  // ─── POST /subscriptions/purchase ─────────────────────────────────────────
  Future<void> subscribePlan() async {
    final plan = selectedPlan;
    if (plan == null) {
      _showError("Please select a plan first.");
      return;
    }

    try {
      isPurchasing.value = true;

      final response = await CreateMinerRepo.purchaseSubscription(
        planId: plan.id,
        planName: plan.displayName,
      );

      if (response != null && response['success'] == true) {
        AppSnackbar.success(
          response['message'] ?? "Miner subscribed successfully!",
          title: "🎉 Success!",
        );

        // Back to previous screen after success
        await Future.delayed(const Duration(milliseconds: 800));
        Get.back(result: true); // result: true = trigger parent refresh
      } else {
        _showError(response?['message'] ?? "Purchase failed. Try again.");
      }
    } catch (e) {
      log("CreateMinerController: subscribePlan error → $e");
      _showError("Something went wrong. Please try again.");
    } finally {
      isPurchasing.value = false;
    }
  }

  // ─── Helper ───────────────────────────────────────────────────────────────
  void _showError(String msg) {
    AppSnackbar.error(msg);
  }
}
