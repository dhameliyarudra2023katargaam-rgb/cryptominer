import 'dart:developer';
import 'package:get/get.dart';
import '../../Repo/referral_repo.dart';
import 'referral_model.dart';

class ReferralController extends GetxController {
  // ─── Observable State ────────────────────────────────────────────────────

  /// GET /referrals/info → referral code, link, total count, rewards earned
  final Rxn<ReferralInfo> referralInfo = Rxn<ReferralInfo>();

  /// GET /referrals/users → list of referred users
  final RxList<ReferredUser> referredUsers = <ReferredUser>[].obs;

  /// GET /referrals/rewards → detailed reward breakdown
  final RxList<ReferralReward> referralRewards = <ReferralReward>[].obs;

  // ─── Loading Flags ────────────────────────────────────────────────────────
  final RxBool isLoadingInfo = false.obs;
  final RxBool isLoadingUsers = false.obs;
  final RxBool isLoadingRewards = false.obs;

  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    fetchAllReferralData();
  }

  /// Fetch all 3 APIs in parallel when screen opens
  Future<void> fetchAllReferralData() async {
    await Future.wait([
      fetchReferralInfo(),
      fetchReferredUsers(),
      fetchReferralRewards(),
    ]);
  }

  // ─── GET /referrals/info ─────────────────────────────────────────────────

  Future<void> fetchReferralInfo() async {
    try {
      isLoadingInfo.value = true;
      final response = await ReferralRepo.getReferralInfo();

      if (response != null && response['success'] == true) {
        final raw = response['data'];
        if (raw != null && raw is Map<String, dynamic>) {
          referralInfo.value = ReferralInfo.fromJson(raw);
          log("Referral info loaded: code=${referralInfo.value?.referralCode}");
        }
      } else {
        log("Failed to load referral info: ${response?['message']}");
      }
    } catch (e) {
      log("fetchReferralInfo error: $e");
    } finally {
      isLoadingInfo.value = false;
    }
  }

  // ─── GET /referrals/users ─────────────────────────────────────────────────

  Future<void> fetchReferredUsers() async {
    try {
      isLoadingUsers.value = true;
      final response = await ReferralRepo.getReferredUsers();

      if (response != null && response['success'] == true) {
        final rawList = response['data'];
        List<dynamic> list = [];
        if (rawList is List) {
          list = rawList;
        } else if (rawList is Map && rawList['users'] is List) {
          list = rawList['users'] as List;
        }
        referredUsers.value = list
            .map((e) => ReferredUser.fromJson(e as Map<String, dynamic>))
            .toList();
        log("Fetched ${referredUsers.length} referred users");
      }
    } catch (e) {
      log("fetchReferredUsers error: $e");
    } finally {
      isLoadingUsers.value = false;
    }
  }

  // ─── GET /referrals/rewards ───────────────────────────────────────────────

  Future<void> fetchReferralRewards() async {
    try {
      isLoadingRewards.value = true;
      final response = await ReferralRepo.getReferralRewards();

      if (response != null && response['success'] == true) {
        final rawList = response['data'];
        List<dynamic> list = [];
        if (rawList is List) {
          list = rawList;
        } else if (rawList is Map && rawList['rewards'] is List) {
          list = rawList['rewards'] as List;
        }
        referralRewards.value = list
            .map((e) => ReferralReward.fromJson(e as Map<String, dynamic>))
            .toList();
        log("Fetched ${referralRewards.length} referral rewards");
      }
    } catch (e) {
      log("fetchReferralRewards error: $e");
    } finally {
      isLoadingRewards.value = false;
    }
  }

  // ─── UI Helpers ──────────────────────────────────────────────────────────

  /// Referral code to show / copy (fallback to placeholder)
  String get displayReferralCode =>
      referralInfo.value?.referralCode ?? '—';

  /// Referral link to copy
  String get displayReferralLink =>
      referralInfo.value?.referralLink ?? '—';

  /// Total rewards formatted
  String get displayTotalRewards =>
      referralInfo.value?.totalRewardsEarned ?? '0.00000000';

  /// Number of referred users
  int get totalReferralCount =>
      referralInfo.value?.totalReferrals ?? referredUsers.length;
}
