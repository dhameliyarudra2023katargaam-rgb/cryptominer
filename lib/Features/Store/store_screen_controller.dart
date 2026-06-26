import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Repo/store_repo.dart';
import 'store_model.dart';

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

  /// Convenience: fetch plans + current subscription together on screen open
  Future<void> fetchAllStoreData() async {
    await Future.wait([
      fetchSubscriptionPlans(),
      fetchCurrentSubscription(),
      fetchSubscriptionHistory(),
    ]);
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
        Get.snackbar(
          "Success 🎉",
          response['message'] ?? "Plan purchased successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        // Refresh current subscription & history after purchase
        await Future.wait([
          fetchCurrentSubscription(),
          fetchSubscriptionHistory(),
        ]);
        selectedPlanIndex.value = -1;
      } else {
        Get.snackbar(
          "Purchase Failed",
          response?['message'] ?? "Something went wrong",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log("purchasePlan error: $e");
      Get.snackbar(
        "Error",
        "Something went wrong",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
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
    if (sub == null) return "No Active Plan";
    return "${sub.planDisplayName} • ${sub.miningSpeed.toStringAsFixed(0)} GH/s";
  }

  /// True if user has any active subscription
  bool get hasActivePlan => currentSubscription.value != null;
}
