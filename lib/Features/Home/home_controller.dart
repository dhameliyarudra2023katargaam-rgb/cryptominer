import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Repo/home_screen_mining_repo.dart';
import '../../Service/storage_service.dart';
import '../../Auth/mpin_unlock_screen.dart';
import '../../Auth/mpin_controller.dart';

class HomeController extends GetxController {
  final RxString dashboardMiningSpeed = "0.0".obs;
  final RxInt dashboardGpus = 0.obs;
  final RxInt dashboardMiners = 0.obs;
  final RxInt collectionPower = 90.obs;
  final RxBool isDashboardLoading = false.obs;

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
