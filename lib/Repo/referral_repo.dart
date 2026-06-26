import 'dart:developer';
import '../Api/api_const.dart';
import '../Api/api_handler.dart';
import '../Service/storage_service.dart';

class ReferralRepo {
  /// Build auth header from saved token
  static Map<String, String> _authHeader() {
    final String? token = SharedPrefHelper.getString("token");
    if (token != null && token.isNotEmpty) {
      return {"Authorization": "Bearer $token"};
    }
    return {};
  }

  // ───────────────────────────────────────────────────────────────────────────
  // GET /referrals/info
  // Returns referral code, link, total referrals, total rewards earned
  // ───────────────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getReferralInfo() async {
    final response = await ApiService().getResponse(
      apiType: APIType.aGet,
      url: "${ApiConst.baseUrl}${ApiConst.ReferralsInfoApi}",
      header: _authHeader(),
    );
    log("Get Referral Info Response: $response");
    if (response is Map<String, dynamic>) return response;
    return null;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // GET /referrals/users
  // Returns list of users referred by this user
  // ───────────────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getReferredUsers() async {
    final response = await ApiService().getResponse(
      apiType: APIType.aGet,
      url: "${ApiConst.baseUrl}${ApiConst.ReferralsUserApi}",
      header: _authHeader(),
    );
    log("Get Referred Users Response: $response");
    if (response is Map<String, dynamic>) return response;
    return null;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // GET /referrals/rewards
  // Returns breakdown of referral rewards earned
  // ───────────────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getReferralRewards() async {
    final response = await ApiService().getResponse(
      apiType: APIType.aGet,
      url: "${ApiConst.baseUrl}${ApiConst.ReferralsRewardsApi}",
      header: _authHeader(),
    );
    log("Get Referral Rewards Response: $response");
    if (response is Map<String, dynamic>) return response;
    return null;
  }
}
