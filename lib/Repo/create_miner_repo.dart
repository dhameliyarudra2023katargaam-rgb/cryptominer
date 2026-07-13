import 'dart:developer';
import '../../Api/api_const.dart';
import '../../Api/api_handler.dart';
import '../../Service/storage_service.dart';
import '../Api/api_const.dart';
import '../Api/api_handler.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CreateMinerRepo - same API use
// GET  /subscriptions/plans    → plans list
// POST /subscriptions/purchase → subscribe
// ─────────────────────────────────────────────────────────────────────────────

class CreateMinerRepo {
  /// Auth header - token take header create
  static Map<String, String> _authHeader() {
    final String? token = SharedPrefHelper.getString("token");
    if (token != null && token.isNotEmpty) {
      return {"Authorization": "Bearer $token"};
    }
    return {};
  }

  // ──────────────────────────────────────────────────────────────────────────
  // GET /subscriptions/plans
  // all available plans fetch
  // ──────────────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getSubscriptionPlans() async {
    try {
      final response = await ApiService().getResponse(
        apiType: APIType.aGet,
        url: "${ApiConst.baseUrl}${ApiConst.SubscriptionPlanApi}",
        header: _authHeader(),
      );
      log("CreateMinerRepo: getSubscriptionPlans → $response");
      if (response is Map<String, dynamic>) return response;
    } catch (e) {
      log("CreateMinerRepo: getSubscriptionPlans error → $e");
    }
    return null;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // POST /subscriptions/purchase
  // body: { "planId": "...", "paymentMethod": "CRYPTO" }
  // ──────────────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> purchaseSubscription({
    required String planId,
    required String planName,
    String paymentMethod = "CRYPTO",
  }) async {
    try {
      final String? token = SharedPrefHelper.getString("token");
      final Map<String, String> headers = {
        "Content-Type": "application/json",
        if (token != null && token.isNotEmpty)
          "Authorization": "Bearer $token",
      };

      final body = {
        "planId": planId,
        "planName": planName,
        "paymentMethod": paymentMethod,
      };

      final response = await ApiService().getResponse(
        apiType: APIType.aPost,
        url: "${ApiConst.baseUrl}${ApiConst.SubscriptionPlanPurchaseApi}",
        body: body,
        header: headers,
      );
      log("CreateMinerRepo: purchaseSubscription → $response");
      if (response is Map<String, dynamic>) return response;
    } catch (e) {
      log("CreateMinerRepo: purchaseSubscription error → $e");
    }
    return null;
  }
}
