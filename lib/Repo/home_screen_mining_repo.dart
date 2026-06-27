import 'dart:developer';
import '../Api/api_const.dart';
import '../Api/api_handler.dart';
import '../Service/storage_service.dart';
import '../Features/Home/home_model.dart';

class MiningRepo {
  /// Get Mining Configuration
  static Future<Map<String, dynamic>?> getMiningConfig() async {
    final String? token = SharedPrefHelper.getString("token");
    Map<String, String> headers = {};
    if (token != null && token.isNotEmpty) {
      headers = {"Authorization": "Bearer $token"};
    }
    var response = await ApiService().getResponse(
      apiType: APIType.aGet,
      url: "${ApiConst.baseUrl}/admin/mining/config",
      header: headers,
    );
    log("Get Mining Config Response: $response");
    if (response is Map<String, dynamic>) {
      return response;
    }
    return null;
  }

  /// Update Mining Configuration (PATCH)
  static Future<Map<String, dynamic>?> updateMiningConfig(Map<String, dynamic> body) async {
    final String? token = SharedPrefHelper.getString("token");
    Map<String, String> headers = {"Content-Type": "application/json"};
    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }
    var response = await ApiService().getResponse(
      apiType: APIType.aPatch,
      url: "${ApiConst.baseUrl}/admin/mining/config",
      body: body,
      header: headers,
    );
    log("Update Mining Config Response: $response");
    if (response is Map<String, dynamic>) {
      return response;
    }
    return null;
  }

  /// Get Admin User Sessions
  static Future<Map<String, dynamic>?> getAdminMiningSessions({int page = 1, int limit = 10}) async {
    final String? token = SharedPrefHelper.getString("token");
    Map<String, String> headers = {};
    if (token != null && token.isNotEmpty) {
      headers = {"Authorization": "Bearer $token"};
    }
    var response = await ApiService().getResponse(
      apiType: APIType.aGet,
      url: "${ApiConst.baseUrl}/admin/mining/sessions?page=$page&limit=$limit",
      header: headers,
    );
    log("Get Admin Mining Sessions Response: $response");
    if (response is Map<String, dynamic>) {
      return response;
    }
    return null;
  }

  /// Get Ad Token
  static Future<Map<String, dynamic>?> getAdToken() async {
    final String? token = SharedPrefHelper.getString("token");
    Map<String, String> headers = {};
    if (token != null && token.isNotEmpty) {
      headers = {"Authorization": "Bearer $token"};
    }
    var response = await ApiService().getResponse(
      apiType: APIType.aGet,
      url: "${ApiConst.baseUrl}${ApiConst.adTokenApi}",
      header: headers,
    );
    log("Get Ad Token Response: $response");
    if (response is Map<String, dynamic>) {
      return response;
    }
    return null;
  }

  /// Start Mining
  static Future<StartMiningResponse?> startMining({
    bool adCompleted = true,
  }) async {
    final String? token = SharedPrefHelper.getString("token");
    Map<String, String> headers = {"Content-Type": "application/json"};
    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }
    var response = await ApiService().getResponse(
      apiType: APIType.aPost,
      url: "${ApiConst.baseUrl}${ApiConst.startMiningApi}",
      body: {"adCompleted": adCompleted},
      header: headers,
    );
    log("Start Mining Response: $response");
    if (response is Map<String, dynamic>) {
      return StartMiningResponse.fromJson(response);
    }
    return null;
  }

  /// Stop Mining
  static Future<StopMiningResponse?> stopMining() async {
    final String? token = SharedPrefHelper.getString("token");

    Map<String, String> headers = {"Content-Type": "application/json"};
    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }
    var response = await ApiService().getResponse(
      apiType: APIType.aPost,
      url: "${ApiConst.baseUrl}${ApiConst.stopMiningApi}",
      body: {},
      header: headers,
    );
    log("Stop Mining Response: $response");
    if (response is Map<String, dynamic>) {
      return StopMiningResponse.fromJson(response);
    }
    return null;
  }

  /// Get Mining Status
  static Future<Map<String, dynamic>?> getMiningStatus() async {
    final String? token = SharedPrefHelper.getString("token");
    Map<String, String> headers = {};
    if (token != null && token.isNotEmpty) {
      headers = {"Authorization": "Bearer $token"};
    }
    var response = await ApiService().getResponse(
      apiType: APIType.aGet,
      url: "${ApiConst.baseUrl}${ApiConst.miningStatusApi}",
      header: headers,
    );
    log("Get Mining Status Response: $response");
    if (response is Map<String, dynamic>) {
      return response;
    }
    return null;
  }

  /// Get Mining History
  static Future<Map<String, dynamic>?> getMiningHistory() async {
    final String? token = SharedPrefHelper.getString("token");
    Map<String, String> headers = {};
    if (token != null && token.isNotEmpty) {
      headers = {"Authorization": "Bearer $token"};
    }
    var response = await ApiService().getResponse(
      apiType: APIType.aGet,
      url: "${ApiConst.baseUrl}${ApiConst.miningHistoryApi}",
      header: headers,
    );
    log("Get Mining History Response: $response");
    if (response is Map<String, dynamic>) {
      return response;
    }
    return null;
  }

  /// Get User Dashboard
  static Future<Map<String, dynamic>?> getUserDashboard() async {
    final String? token = SharedPrefHelper.getString("token");
    Map<String, String> headers = {};
    if (token != null && token.isNotEmpty) {
      headers = {"Authorization": "Bearer $token"};
    }
    var response = await ApiService().getResponse(
      apiType: APIType.aGet,
      url: "${ApiConst.baseUrl}${ApiConst.dashboardApi}",
      header: headers,
    );
    log("Get User Dashboard Response: $response");
    if (response is Map<String, dynamic>) {
      return response;
    }
    return null;
  }
}
