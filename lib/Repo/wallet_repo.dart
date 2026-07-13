import 'dart:developer';
import '../Api/api_const.dart';
import '../Api/api_handler.dart';
import '../Service/storage_service.dart';

class WalletRepo {
  /// Get Wallet Balance
  static Future<Map<String, dynamic>?> getWalletBalance() async {
    Map<String, String> headers = {};
    var response = await ApiService().getResponse(
      apiType: APIType.aGet,
      url: "${ApiConst.baseUrl}${ApiConst.walletBalanceApi}",
      header: headers,
    );
    log("Get Wallet Balance Response: $response");
    if (response is Map<String, dynamic>) {
      return response;
    }
    return null;
  }

  /// Get Wallet Transactions
  static Future<Map<String, dynamic>?> getWalletTransactions() async {
    Map<String, String> headers = {};
    var response = await ApiService().getResponse(
      apiType: APIType.aGet,
      url: "${ApiConst.baseUrl}${ApiConst.walletTransactionsApi}",
      header: headers,
    );
    log("Get Wallet Transactions Response: $response");
    if (response is Map<String, dynamic>) {
      return response;
    }
    return null;
  }

  /// Request Withdrawal
  static Future<Map<String, dynamic>?> requestWithdrawal(Map<String, dynamic> body) async {
    final String? token = SharedPrefHelper.getString("token");
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }
    var response = await ApiService().getResponse(
      apiType: APIType.aPost,
      url: "${ApiConst.baseUrl}${ApiConst.withdrawalsRequestApi}",
      body: body,
      header: headers,
    );
    log("Request Withdrawal Response: $response");
    if (response is Map<String, dynamic>) {
      return response;
    }
    return null;
  }

  /// Get Withdrawal History
  static Future<Map<String, dynamic>?> getWithdrawalHistory() async {
    Map<String, String> headers = {};
    var response = await ApiService().getResponse(
      apiType: APIType.aGet,
      url: "${ApiConst.baseUrl}${ApiConst.withdrawalsHistoryApi}",
      header: headers,
    );
    log("Get Withdrawal History Response: $response");
    if (response is Map<String, dynamic>) {
      return response;
    }
    return null;
  }
}
