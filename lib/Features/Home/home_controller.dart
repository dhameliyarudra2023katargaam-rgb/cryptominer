import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Repo/home_screen_mining_repo.dart';
import '../../Service/storage_service.dart';
import '../../Auth/mpin_unlock_screen.dart';
import '../../Auth/mpin_controller.dart';
import '../../Service/Ads/ad_service.dart';
import '../../Service/socket_service.dart';
import '../Store/store_screen_controller.dart';

class HomeController extends GetxController {
  final RxString dashboardMiningSpeed = "0.0".obs;
  final RxInt dashboardGpus = 0.obs;
  final RxInt dashboardMiners = 0.obs;
  final RxInt collectionPower = 95.obs;
  Timer? _powerTimer;
  final RxBool isDashboardLoading = false.obs;

  // Boost and Config reactive variables
  final RxBool isBoosting = false.obs;
  final RxInt boostRemainingSeconds = 0.obs; // 5-min countdown
  Timer? _boostTimer;
  final RxMap<String, dynamic> miningConfig = <String, dynamic>{}.obs;

  double get effectiveMiningSpeed {
    // 1. Base Free Speed (10 GH/s always active by default)
    double baseSpeed = 10.0;
    
    // 2. Paid Plan Speed (Overrides the base free speed if active)
    if (Get.isRegistered<StoreController>()) {
      final storeCtrl = Get.find<StoreController>();
      if (storeCtrl.hasActivePlan) {
        baseSpeed = storeCtrl.currentSubscription.value?.miningSpeed ?? 10.0;
      }
    }

    // 3. Boost Speed from Mining Config
    double boostSpeed = 0.0;
    if (isBoosting.value) {
      boostSpeed = double.tryParse(miningConfig['adSpeedBonus']?.toString() ?? "100") ?? 100.0;
    }

    return baseSpeed + boostSpeed;
  }

  double get effectiveFreeMiningSpeed {
    double baseSpeed = 10.0;
    
    double boostSpeed = 0.0;
    if (isBoosting.value) {
      boostSpeed = double.tryParse(miningConfig['adSpeedBonus']?.toString() ?? "100") ?? 100.0;
    }

    return baseSpeed + boostSpeed;
  }

  int get effectiveGpus {
    int base = dashboardGpus.value;
    if (isBoosting.value) {
      base += int.tryParse(miningConfig['adGpuCount']?.toString() ?? "0") ?? 0;
    }
    return base;
  }

  int get effectiveMiners {
    int base = dashboardMiners.value;
    if (isBoosting.value) {
      base += int.tryParse(miningConfig['adMinerCount']?.toString() ?? "0") ?? 0;
    }
    return base;
  }

  @override
  void onInit() {
    super.onInit();
    _startPowerFluctuation();
    fetchMiningConfig();
  }

  void _startPowerFluctuation() {
    _powerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // Random value between 90 and 100
      collectionPower.value = 90 + Random().nextInt(11);
    });
  }

  /// Fetch Mining Config from backend
  Future<void> fetchMiningConfig() async {
    try {
      final response = await MiningRepo.getMiningConfig();
      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data != null && data is Map<String, dynamic>) {
          miningConfig.value = data;
          return;
        }
      }
      _setDefaultMiningConfig();
    } catch (e) {
      debugPrint("Error fetching mining config: $e");
      _setDefaultMiningConfig();
    }
  }

  void _setDefaultMiningConfig() {
    miningConfig.value = {
      "adType": "rewarded",
      "bypassAdOnError": true,
      "adSpeedBonus": 100,
      "adBonusDurationMinutes": 10,
    };
  }

  /// Trigger speed boost flow
  Future<void> triggerBoost() async {
    if (isBoosting.value) {
      debugPrint("Boost is already in progress.");
      return;
    }
    isBoosting.value = true;

    try {
      // 1. Show rewarded ad — wait for user to fully watch it
      final bool adWatched = await AdService.instance.showAd(
        adType: 'rewarded',
        retryOnFailure: false,
      );

      // 2. After ad is done (watched or failed), call API
      if (adWatched) {
        await _executeBoostApiCall();
      } else {
        // Ad failed — still give boost (bypass) but release if API also fails
        await _executeBoostApiCall(warningMessage: "Boost activated (Ad unavailable)");
      }
    } catch (e) {
      debugPrint("Error during boost flow: $e");
      isBoosting.value = false;
      Get.snackbar(
        "Error",
        "An unexpected error occurred: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }




  /// Start cooldown timer after successful boost
  void _startBoostCooldown() {
    _boostTimer?.cancel();
    
    // Get duration from config, default to 10 minutes if not found
    int durationMinutes = int.tryParse(miningConfig['adBonusDurationMinutes']?.toString() ?? "10") ?? 10;
    boostRemainingSeconds.value = durationMinutes * 60;
    
    isBoosting.value = true;
    _boostTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (boostRemainingSeconds.value <= 1) {
        timer.cancel();
        boostRemainingSeconds.value = 0;
        isBoosting.value = false;
      } else {
        boostRemainingSeconds.value--;
      }
    });
  }

  /// Call the API to claim boost/ad token and refresh UI data
  Future<void> _executeBoostApiCall({String? warningMessage}) async {
    final response = await MiningRepo.getAdToken();
    if (response != null && response['success'] == true) {
      int durationMinutes = int.tryParse(miningConfig['adBonusDurationMinutes']?.toString() ?? "10") ?? 10;
      Get.snackbar(
        warningMessage != null ? "Warning" : "Success",
        warningMessage ?? "Speed boost activated! $durationMinutes min duration started.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: warningMessage != null
            ? Colors.orange.withValues(alpha: 0.9)
            : Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
      );

      // Refresh mining status and dashboard speed
      if (Get.isRegistered<SocketService>()) {
        await Get.find<SocketService>().fetchMiningStatus();
      }
      await fetchDashboardData();

      // Start 5-minute cooldown
      _startBoostCooldown();
    } else {
      // API failed — release boost lock
      isBoosting.value = false;
      Get.snackbar(
        "API Error",
        response?['message'] ?? "Failed to activate speed boost",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      isDashboardLoading.value = true;
      final response = await MiningRepo.getUserDashboard();
      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data != null && data is Map) {
          dashboardMiningSpeed.value = data['miningSpeed']?.toString() ?? "0.0";
          dashboardGpus.value = data['gpus'] is int
              ? data['gpus']
              : int.tryParse(data['gpus']?.toString() ?? "0") ?? 0;
          dashboardMiners.value = data['miners'] is int
              ? data['miners']
              : int.tryParse(data['miners']?.toString() ?? "0") ?? 0;
          final rawPower = data['collectionPower'] ?? data['collection_power'] ?? data['power'];
          // We can ignore the rawPower if we want it to always fluctuate randomly between 90 and 100
          // Or update the base value. For now, the timer handles the 90-100 logic.

          // Check if MPIN is set
          final bool isMpinSet = data['isMpinSet'] == true;
          if (isMpinSet && !MpinController.isSessionUnlocked) {
            await SharedPrefHelper.setBool("hasMpin", true);
            Get.offAll(() => const MpinUnlockScreen());
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching dashboard data: $e");
    } finally {
      isDashboardLoading.value = false;
    }
  }

  @override
  void onClose() {
    _boostTimer?.cancel();
    _powerTimer?.cancel();
    super.onClose();
  }
}
