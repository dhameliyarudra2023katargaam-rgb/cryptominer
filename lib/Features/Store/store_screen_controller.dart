import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utility/app_snackbar.dart';
import '../../Repo/store_repo.dart';
import '../../Repo/home_screen_mining_repo.dart';
import 'package:cryptominer/Features/Store/store_model.dart';

class StoreController extends GetxController {
  // ─── Observable State ────────────────────────────────────────────────────

  /// All available plans from GET /subscriptions/plans
  final RxList<SubscriptionPlan> plans = <SubscriptionPlan>[].obs;

  /// Currently active subscription from GET /subscriptions/current
  final Rxn<CurrentSubscription> currentSubscription = Rxn<CurrentSubscription>();

  /// Past subscription history from GET /subscriptions/history
  final RxList<SubscriptionHistory> subscriptionHistory = <SubscriptionHistory>[].obs;

  /// Index of the plan the user has tapped/selected in the UI
  final RxInt selectedPlanIndex = (-1).obs;

  // ─── Loading Flags ────────────────────────────────────────────────────────
  final RxBool isLoadingPlans = false.obs;
  final RxBool isLoadingCurrent = false.obs;
  final RxBool isLoadingHistory = false.obs;
  final RxBool isPurchasing = false.obs;

  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    // Fetch everything when the controller is first created
    fetchAllStoreData();
  }

  Future<void> fetchAllStoreData() async {
    await Future.wait([
      fetchSubscriptionPlans(),
      fetchCurrentSubscription(),
      fetchSubscriptionHistory(),
      fetchFreeMiningData(),
    ]);
  }

  // ─── GET /mining/start ────────────────────────────────────────────────
  final RxMap<String, dynamic> freeMiningData = <String, dynamic>{}.obs;
  final RxBool isLoadingFreeMining = false.obs;

  Future<void> fetchFreeMiningData() async {
    try {
      isLoadingFreeMining.value = true;
      final response = await StoreRepo.getFreeMiningData();
      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data is List && data.isNotEmpty) {
          freeMiningData.value = data[0] as Map<String, dynamic>;
          log("Fetched free mining data (from list): ${freeMiningData.value}");
        } else if (data != null && data is Map<String, dynamic>) {
          freeMiningData.value = data;
          log("Fetched free mining data (map): ${freeMiningData.value}");
        }
      }
    } catch (e) {
      log("fetchFreeMiningData error: $e");
    } finally {
      isLoadingFreeMining.value = false;
    }
  }

  // ─── GET /subscriptions/plans ────────────────────────────────────────────

  Future<void> fetchSubscriptionPlans() async {
    try {
      isLoadingPlans.value = true;
      final response = await StoreRepo.getSubscriptionPlans();

      if (response != null && response['success'] == true) {
        final rawList = response['data'];
        // Support { data: [...] } or { data: { plans: [...] } }
        List<dynamic> list = [];
        if (rawList is List) {
          list = rawList;
        } else if (rawList is Map && rawList['plans'] is List) {
          list = rawList['plans'] as List;
        }
        plans.value = list
            .map((e) => SubscriptionPlan.fromJson(e as Map<String, dynamic>))
            .toList();
        log("Fetched ${plans.length} subscription plans");
      } else {
        log("Failed to fetch plans: ${response?['message']}");
      }

      if (plans.isEmpty) {
        plans.value = [
          SubscriptionPlan(id: "plan_1", name: "10 GH/s", displayName: "10 GH/s Miner", price: 0.0, miningSpeed: 10.0, aprPercent: 0.0, freeCpuPercent: 0.0, discountText: "0.0333 \$/Month"),
          SubscriptionPlan(id: "plan_2", name: "20 GH/s", displayName: "20 GH/s Miner", price: 0.0, miningSpeed: 20.0, aprPercent: 0.0, freeCpuPercent: 0.0, discountText: "0.0667 \$/Month"),
          SubscriptionPlan(id: "plan_3", name: "50 GH/s", displayName: "50 GH/s Miner", price: 0.0, miningSpeed: 50.0, aprPercent: 0.0, freeCpuPercent: 0.0, discountText: "0.1667 \$/Month"),
          SubscriptionPlan(id: "plan_4", name: "100 GH/s", displayName: "100 GH/s Miner", price: 0.0, miningSpeed: 100.0, aprPercent: 0.0, freeCpuPercent: 0.0, discountText: "0.3333 \$/Month"),
          SubscriptionPlan(id: "plan_5", name: "1 TH/s", displayName: "1 TH/s Miner", price: 0.0, miningSpeed: 1000.0, aprPercent: 0.0, freeCpuPercent: 0.0, discountText: "3.3333 \$/Month"),
          SubscriptionPlan(id: "plan_6", name: "10 TH/s", displayName: "10 TH/s Miner", price: 0.0, miningSpeed: 10000.0, aprPercent: 0.0, freeCpuPercent: 0.0, discountText: "33.3333 \$/Month"),
        ];
      }
    } catch (e) {
      log("fetchSubscriptionPlans error: $e");
    } finally {
      isLoadingPlans.value = false;
    }
  }

  // ─── GET /subscriptions/current ─────────────────────────────────────────

  Future<void> fetchCurrentSubscription() async {
    try {
      isLoadingCurrent.value = true;
      final response = await StoreRepo.getCurrentSubscription();

      if (response != null && response['success'] == true) {
        final raw = response['data'];
        if (raw != null && raw is Map<String, dynamic>) {
          currentSubscription.value = CurrentSubscription.fromJson(raw);
          log("Current subscription: ${currentSubscription.value?.planDisplayName}");
        } else {
          // No active subscription
          currentSubscription.value = null;
        }
      } else {
        currentSubscription.value = null;
        log("No current subscription: ${response?['message']}");
      }
    } catch (e) {
      log("fetchCurrentSubscription error: $e");
    } finally {
      isLoadingCurrent.value = false;
    }
  }

  // ─── GET /subscriptions/history ─────────────────────────────────────────

  Future<void> fetchSubscriptionHistory() async {
    try {
      isLoadingHistory.value = true;
      final response = await StoreRepo.getSubscriptionHistory();

      if (response != null && response['success'] == true) {
        final rawList = response['data'];
        List<dynamic> list = [];
        if (rawList is List) {
          list = rawList;
        } else if (rawList is Map && rawList['subscriptions'] is List) {
          list = rawList['subscriptions'] as List;
        }
        subscriptionHistory.value = list
            .map((e) => SubscriptionHistory.fromJson(e as Map<String, dynamic>))
            .toList();
        log("Fetched ${subscriptionHistory.length} subscription history items");
      }
    } catch (e) {
      log("fetchSubscriptionHistory error: $e");
    } finally {
      isLoadingHistory.value = false;
    }
  }

  // ─── POST /subscriptions/purchase ────────────────────────────────────────

  Future<void> purchasePlan(SubscriptionPlan plan) async {
    try {
      isPurchasing.value = true;

      final body = {
        "planId": plan.id,
        "paymentMethod": "CRYPTO",
      };

      final response = await StoreRepo.purchaseSubscription(body);

      if (response != null && response['success'] == true) {
        AppSnackbar.success(
          response['message'] ?? "Plan purchased successfully!",
          title: "Success 🎉",
        );
        // Refresh current subscription & history after purchase
        await Future.wait([
          fetchCurrentSubscription(),
          fetchSubscriptionHistory(),
        ]);
        selectedPlanIndex.value = -1;
      } else {
        AppSnackbar.error(
          response?['message'] ?? "Something went wrong",
          title: "Purchase Failed",
        );
      }
    } catch (e) {
      log("purchasePlan error: $e");
      AppSnackbar.error("Something went wrong");
    } finally {
      isPurchasing.value = false;
    }
  }

  // ─── UI Helpers ──────────────────────────────────────────────────────────

  void selectPlan(int index) {
    selectedPlanIndex.value = index;
  }

  /// Active mining power label for the top card
  String get activeMiningLabel {
    final sub = currentSubscription.value;
    if (sub == null || sub.planName == "plan_1" || sub.planName == "10 GH/s" || sub.miningSpeed <= 10.0) {
      return "10 GH/s Miner";
    }
    final speedText = sub.miningSpeed >= 1000
        ? "${(sub.miningSpeed / 1000).toStringAsFixed(0)} TH/s"
        : "${sub.miningSpeed.toStringAsFixed(0)} GH/s";
    return "${sub.planDisplayName} • $speedText";
  }

  /// True if user has any active subscription
  bool get hasActivePlan {
    final sub = currentSubscription.value;
    if (sub == null) return false;
    if (sub.planName == "plan_1" || sub.planName == "10 GH/s") return false;
    if (sub.miningSpeed <= 10.0) return false;
    return true;
  }
}
