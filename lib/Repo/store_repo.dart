import 'dart:developer';
import '../Api/api_const.dart';
import '../Api/api_handler.dart';
import '../Service/storage_service.dart';

class StoreRepo {
  /// Build auth header from saved token
  static Map<String, String> _authHeader() {
    final String? token = SharedPrefHelper.getString("token");
    if (token != null && token.isNotEmpty) {
      return {"Authorization": "Bearer $token"};
    }
    return {};
  }

  // ───────────────────────────────────────────────────────────────────────────
  // GET /subscriptions/plans
  // Returns list of available subscription plans
  // ───────────────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getSubscriptionPlans() async {
    final response = await ApiService().getResponse(
      apiType: APIType.aGet,
      url: "${ApiConst.baseUrl}${ApiConst.SubscriptionPlanApi}",
      header: _authHeader(),
    );
    print("StoreRepo: getSubscriptionPlans response success: ${response?['success']}");
    log("Get Subscription Plans Response: $response");
    if (response is Map<String, dynamic>) return response;
    return null;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // GET /subscriptions/current
  // Returns the user's currently active subscription (null if none)
  // ───────────────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getCurrentSubscription() async {
    final response = await ApiService().getResponse(
      apiType: APIType.aGet,
      url: "${ApiConst.baseUrl}${ApiConst.CurrentSubscriptionPlanApi}",
      header: _authHeader(),
    );
    print("StoreRepo: getCurrentSubscription response success: ${response?['success']}");
    log("Get Current Subscription Response: $response");
    if (response is Map<String, dynamic>) return response;
    return null;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // POST /subscriptions/purchase
  // body: { "planId": "...", "paymentMethod": "CRYPTO" }
  // ───────────────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> purchaseSubscription(
      Map<String, dynamic> body) async {
    final String? token = SharedPrefHelper.getString("token");
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }
    final response = await ApiService().getResponse(
      apiType: APIType.aPost,
      url: "${ApiConst.baseUrl}${ApiConst.SubscriptionPlanPurchaseApi}",
      body: body,
      header: headers,
    );
    print("StoreRepo: purchaseSubscription response success: ${response?['success']}");
    log("Purchase Subscription Response: $response");
    if (response is Map<String, dynamic>) return response;
    return null;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // GET /subscriptions/history
  // Returns paginated list of past subscriptions
  // ───────────────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getSubscriptionHistory() async {
    final response = await ApiService().getResponse(
      apiType: APIType.aGet,
      url: "${ApiConst.baseUrl}${ApiConst.AllSubscriptionPlanHistoryApi}",
      header: _authHeader(),
    );
    print("StoreRepo: getSubscriptionHistory response success: ${response?['success']}");
    log("Get Subscription History Response: $response");
    if (response is Map<String, dynamic>) return response;
    return null;
  }
}
