import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Repo/home_screen_mining_repo.dart';
import '../../Model/admin_mining_model.dart';
import '../../Service/storage_service.dart';

class AdminMiningConfigController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool sessionsLoading = false.obs;

  // Form Fields Text Controllers
  late TextEditingController baseMiningSpeedController;
  late TextEditingController miningDurationHoursController;
  late TextEditingController baseRewardPerHourController;
  late TextEditingController adSpeedBonusController;
  late TextEditingController adBonusDurationMinutesController;
  late TextEditingController adGpuCountController;
  late TextEditingController adMinerCountController;
  late TextEditingController baseGpuCountController;
  late TextEditingController baseMinerCountController;

  // Sessions list
  final RxList<AdminMiningSession> sessionsList = <AdminMiningSession>[].obs;

  @override
  void onInit() {
    super.onInit();
    baseMiningSpeedController = TextEditingController();
    miningDurationHoursController = TextEditingController();
    baseRewardPerHourController = TextEditingController();
    adSpeedBonusController = TextEditingController();
    adBonusDurationMinutesController = TextEditingController();
    adGpuCountController = TextEditingController();
    adMinerCountController = TextEditingController();
    baseGpuCountController = TextEditingController();
    baseMinerCountController = TextEditingController();

    // Check if there is local config. If yes, populate and start auto-saving on edit. If not, fetch.
    final hasLocal = _loadLocalConfig();
    if (!hasLocal) {
      fetchConfig();
    }
    fetchSessions();
  }

  @override
  void onClose() {
    _removeListeners();
    baseMiningSpeedController.dispose();
    miningDurationHoursController.dispose();
    baseRewardPerHourController.dispose();
    adSpeedBonusController.dispose();
    adBonusDurationMinutesController.dispose();
    adGpuCountController.dispose();
    adMinerCountController.dispose();
    baseGpuCountController.dispose();
    baseMinerCountController.dispose();
    super.onClose();
  }

  /// Save current text controllers to local storage (auto-save draft)
  void _saveLocalConfig() {
    try {
      final config = AdminMiningConfig(
        baseMiningSpeed: num.tryParse(baseMiningSpeedController.text.trim()) ?? 0,
        miningDurationHours: num.tryParse(miningDurationHoursController.text.trim()) ?? 0,
        baseRewardPerHour: baseRewardPerHourController.text.trim(),
        adSpeedBonus: num.tryParse(adSpeedBonusController.text.trim()) ?? 0,
        adBonusDurationMinutes: num.tryParse(adBonusDurationMinutesController.text.trim()) ?? 0,
        adGpuCount: num.tryParse(adGpuCountController.text.trim()) ?? 0,
        adMinerCount: num.tryParse(adMinerCountController.text.trim()) ?? 0,
        baseGpuCount: num.tryParse(baseGpuCountController.text.trim()) ?? 0,
        baseMinerCount: num.tryParse(baseMinerCountController.text.trim()) ?? 0,
      );
      SharedPrefHelper.setString("admin_mining_config", jsonEncode(config.toJson()));
    } catch (e) {
      debugPrint("Failed to save local config: $e");
    }
  }

  /// Load from local storage
  bool _loadLocalConfig() {
    try {
      final cachedStr = SharedPrefHelper.getString("admin_mining_config");
      if (cachedStr != null && cachedStr.isNotEmpty) {
        final decoded = jsonDecode(cachedStr);
        final config = AdminMiningConfig.fromJson(decoded);
        _removeListeners();
        _populateFields(config);
        _addListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Failed to load local config: $e");
    }
    return false;
  }

  void _populateFields(AdminMiningConfig config) {
    baseMiningSpeedController.text = config.baseMiningSpeed.toString();
    miningDurationHoursController.text = config.miningDurationHours.toString();
    baseRewardPerHourController.text = config.baseRewardPerHour;
    adSpeedBonusController.text = config.adSpeedBonus.toString();
    adBonusDurationMinutesController.text = config.adBonusDurationMinutes.toString();
    adGpuCountController.text = config.adGpuCount.toString();
    adMinerCountController.text = config.adMinerCount.toString();
    baseGpuCountController.text = config.baseGpuCount.toString();
    baseMinerCountController.text = config.baseMinerCount.toString();
  }

  void _addListeners() {
    baseMiningSpeedController.addListener(_saveLocalConfig);
    miningDurationHoursController.addListener(_saveLocalConfig);
    baseRewardPerHourController.addListener(_saveLocalConfig);
    adSpeedBonusController.addListener(_saveLocalConfig);
    adBonusDurationMinutesController.addListener(_saveLocalConfig);
    adGpuCountController.addListener(_saveLocalConfig);
    adMinerCountController.addListener(_saveLocalConfig);
    baseGpuCountController.addListener(_saveLocalConfig);
    baseMinerCountController.addListener(_saveLocalConfig);
  }

  void _removeListeners() {
    baseMiningSpeedController.removeListener(_saveLocalConfig);
    miningDurationHoursController.removeListener(_saveLocalConfig);
    baseRewardPerHourController.removeListener(_saveLocalConfig);
    adSpeedBonusController.removeListener(_saveLocalConfig);
    adBonusDurationMinutesController.removeListener(_saveLocalConfig);
    adGpuCountController.removeListener(_saveLocalConfig);
    adMinerCountController.removeListener(_saveLocalConfig);
    baseGpuCountController.removeListener(_saveLocalConfig);
    baseMinerCountController.removeListener(_saveLocalConfig);
  }

  /// Fetch Mining Config from server
  Future<void> fetchConfig() async {
    try {
      isLoading.value = true;
      final response = await MiningRepo.getMiningConfig();
      if (response != null) {
        final configResponse = AdminMiningConfigResponse.fromJson(response);
        if (configResponse.success && configResponse.data != null) {
          final data = configResponse.data!;
          _removeListeners();
          _populateFields(data);
          _addListeners();
          _saveLocalConfig(); // Update local cache
        } else {
          Get.snackbar(
            "Error",
            configResponse.message.isNotEmpty ? configResponse.message : "Failed to load config from server",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to load config from server",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to load config: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch Recent Mining Sessions from server
  Future<void> fetchSessions() async {
    try {
      sessionsLoading.value = true;
      final response = await MiningRepo.getAdminMiningSessions(page: 1, limit: 10);
      if (response != null) {
        final sessionsResponse = AdminMiningSessionsResponse.fromJson(response);
        if (sessionsResponse.success) {
          sessionsList.value = sessionsResponse.data;
        }
      }
    } catch (e) {
      debugPrint("Failed to fetch admin sessions: $e");
    } finally {
      sessionsLoading.value = false;
    }
  }

  /// Save changes using PATCH API
  Future<void> saveConfig() async {
    // Basic Form Validation
    if (baseMiningSpeedController.text.trim().isEmpty ||
        miningDurationHoursController.text.trim().isEmpty ||
        baseRewardPerHourController.text.trim().isEmpty ||
        adSpeedBonusController.text.trim().isEmpty ||
        adBonusDurationMinutesController.text.trim().isEmpty ||
        adGpuCountController.text.trim().isEmpty ||
        adMinerCountController.text.trim().isEmpty ||
        baseGpuCountController.text.trim().isEmpty ||
        baseMinerCountController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation Error",
        "All configuration fields are required.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSaving.value = true;

      final body = {
        "baseMiningSpeed": num.tryParse(baseMiningSpeedController.text.trim()) ?? 0,
        "miningDurationHours": num.tryParse(miningDurationHoursController.text.trim()) ?? 0,
        "baseRewardPerHour": baseRewardPerHourController.text.trim(),
        "adSpeedBonus": num.tryParse(adSpeedBonusController.text.trim()) ?? 0,
        "adBonusDurationMinutes": num.tryParse(adBonusDurationMinutesController.text.trim()) ?? 0,
        "adGpuCount": num.tryParse(adGpuCountController.text.trim()) ?? 0,
        "adMinerCount": num.tryParse(adMinerCountController.text.trim()) ?? 0,
        "baseGpuCount": num.tryParse(baseGpuCountController.text.trim()) ?? 0,
        "baseMinerCount": num.tryParse(baseMinerCountController.text.trim()) ?? 0,
      };

      final response = await MiningRepo.updateMiningConfig(body);
      if (response != null && response['success'] == true) {
        Get.snackbar(
          "Success",
          response['message'] ?? "Mining configuration updated successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        fetchConfig(); // Reload config
      } else {
        Get.snackbar(
          "Save Failed",
          response?['message'] ?? "Failed to update configuration",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred while saving: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
