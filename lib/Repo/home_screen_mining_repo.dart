import 'dart:developer';
import '../Api/api_const.dart';
import '../Api/api_handler.dart';
import '../Service/storage_service.dart';
import '../Features/Home/home_model.dart';

class MiningRepo {
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
