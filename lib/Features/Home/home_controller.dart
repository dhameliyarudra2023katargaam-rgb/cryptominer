import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Repo/home_screen_mining_repo.dart';
import '../../Service/storage_service.dart';
import '../../Auth/mpin_unlock_screen.dart';
import '../../Auth/mpin_controller.dart';
import '../../Service/ad_service.dart';
import '../../Service/socket_service.dart';

class HomeController extends GetxController {
  final RxString dashboardMiningSpeed = "0.0".obs;
  final RxInt dashboardGpus = 0.obs;
  final RxInt dashboardMiners = 0.obs;
  final RxInt collectionPower = 90.obs;
  final RxBool isDashboardLoading = false.obs;

  // Boost and Config reactive variables
  final RxBool isBoosting = false.obs;
  final RxMap<String, dynamic> miningConfig = <String, dynamic>{}.obs;

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
      // 1. Fetch latest system mining config
      await fetchMiningConfig();

      // Determine ad configuration from system config or local defaults
      // e.g. default to rewarded ads
      final String adType = miningConfig['adType']?.toString() ?? 'rewarded';
      final bool bypassAdOnError = miningConfig['bypassAdOnError'] ?? true; 

      Get.snackbar(
        "Loading Ad",
        "Please wait while we load the ad...",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // 2. Load and show the Google Test Ad
      final bool adSuccess = await AdService.instance.showAd(
        adType: adType,
        retryOnFailure: true,
      );

      // 3. API execution check (strictly dependent on ad completion, unless bypass configuration is enabled)
      if (adSuccess) {
        await _executeBoostApiCall();
      } else {
        if (bypassAdOnError) {
          debugPrint("Ad failed to load/show. Proceeding to API call as configured.");
          await _executeBoostApiCall(warningMessage: "Boost activated (Ad failed to load)");
        } else {
          Get.snackbar(
            "Ad Failed",
            "Could not load the advertisement. Please try again later.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      debugPrint("Error during boost flow: $e");
      Get.snackbar(
        "Error",
        "An unexpected error occurred during boost: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      isBoosting.value = false;
    }
  }

  /// Call the API to claim boost/ad token and refresh UI data
  Future<void> _executeBoostApiCall({String? warningMessage}) async {
    final response = await MiningRepo.getAdToken();
    if (response != null && response['success'] == true) {
      Get.snackbar(
        warningMessage != null ? "Warning" : "Success",
        warningMessage ?? "Speed boost activated successfully!",
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
    } else {
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
          if (rawPower != null) {
            collectionPower.value = int.tryParse(rawPower.toString()) ?? 90;
          }

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
}
