import 'dart:developer';
import '../Api/api_const.dart';
import '../Api/api_handler.dart';
import '../Auth/auth_model.dart';
import '../Service/storage_service.dart';

class AuthRepo {
  /// Register User Repo
  static Future<AuthModel> registerUser(Map<String, dynamic> body) async {
    var response = await ApiService().getResponse(
      apiType: APIType.aPost,
      url: "${ApiConst.baseUrl}${ApiConst.registerApi}",
      body: body,
    );
    log("Register User Response: $response");

    return AuthModel.fromJson(response);
  }

  /// Google Login Repo
  static Future<AuthModel> googleLogin(Map<String, dynamic> body) async {
    var response = await ApiService().getResponse(
      apiType: APIType.aPost,
      url: "${ApiConst.baseUrl}${ApiConst.googleApi}",
      body: body,
    );
    log("Google Login Response: $response");

    return AuthModel.fromJson(response);
  }

  /// Firebase Login Repo
  static Future<AuthModel> firebaseLogin(Map<String, dynamic> body) async {
    var response = await ApiService().getResponse(
      apiType: APIType.aPost,
      url: "${ApiConst.baseUrl}${ApiConst.firebaseLoginApi}",
      body: body,
    );
    log("Firebase Login Response: $response");

    return AuthModel.fromJson(response);
  }

  /// Logout User Repo
  static Future<AuthModel> logoutUser() async {
    final String? token = SharedPrefHelper.getString("token");
    Map<String, String> headers = {};
    if (token != null && token.isNotEmpty) {
      headers = {
        "Authorization": "Bearer $token",
      };
    }
    var response = await ApiService().getResponse(
      apiType: APIType.aPost,
      url: "${ApiConst.baseUrl}${ApiConst.logoutApi}",
      header: headers,
    );
    log("Logout Response: $response");

    return AuthModel.fromJson(response);
  }

  /// Get Current User Details Repo
  static Future<AuthModel> getMe() async {
    final String? token = SharedPrefHelper.getString("token");
    Map<String, String> headers = {};
    if (token != null && token.isNotEmpty) {
      headers = {
        "Authorization": "Bearer $token",
      };
    }
    var response = await ApiService().getResponse(
      apiType: APIType.aGet,
      url: "${ApiConst.baseUrl}${ApiConst.meApi}",
      header: headers,
    );
    log("Get Me Response: $response");

    return AuthModel.fromJson(response);
  }

  /// Update Profile Repo
  static Future<AuthModel> updateProfile(Map<String, dynamic> body) async {
    final String? token = SharedPrefHelper.getString("token");
    Map<String, String> headers = {};
    if (token != null && token.isNotEmpty) {
      headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };
    }
    var response = await ApiService().getResponse(
      apiType: APIType.aPut,
      url: "${ApiConst.baseUrl}${ApiConst.updateProfileApi}",
      body: body,
      header: headers,
    );
    log("Update Profile Response: $response");

    return AuthModel.fromJson(response);
  }

  /// Change Password Repo
  static Future<AuthModel> changePassword(Map<String, dynamic> body) async {
    final String? token = SharedPrefHelper.getString("token");
    Map<String, String> headers = {};
    if (token != null && token.isNotEmpty) {
      headers = {
        "Authorization": "Bearer $token",
      };
    }
    var response = await ApiService().getResponse(
      apiType: APIType.aPost,
      url: "${ApiConst.baseUrl}${ApiConst.changePasswordApi}",
      body: body,
      header: headers,
    );
    log("Change Password Response: $response");

    return AuthModel.fromJson(response);
  }

  /// Create MPIN Repo
  static Future<AuthModel> createMpin(Map<String, dynamic> body) async {
    final String? token = SharedPrefHelper.getString("token");
    Map<String, String> headers = {};
    if (token != null && token.isNotEmpty) {
      headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };
    }
    var response = await ApiService().getResponse(
      apiType: APIType.aPost,
      url: "${ApiConst.baseUrl}${ApiConst.createMpinApi}",
      body: body,
      header: headers,
    );
    log("Create MPIN Response: $response");

    return AuthModel.fromJson(response);
  }

  /// Set MPIN Repo
  static Future<AuthModel> setMpin(Map<String, dynamic> body) async {
    final String? token = SharedPrefHelper.getString("token");
    Map<String, String> headers = {};
    if (token != null && token.isNotEmpty) {
      headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };
    }
    var response = await ApiService().getResponse(
      apiType: APIType.aPost,
      url: "${ApiConst.baseUrl}${ApiConst.setMpinApi}",
      body: body,
      header: headers,
    );
    log("Set MPIN Response: $response");

    return AuthModel.fromJson(response);
  }

  /// Login MPIN Repo
  static Future<AuthModel> loginMpin(Map<String, dynamic> body) async {
    final String? token = SharedPrefHelper.getString("token");
    Map<String, String> headers = {};
    if (token != null && token.isNotEmpty) {
      headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };
    }
    var response = await ApiService().getResponse(
      apiType: APIType.aPost,
      url: "${ApiConst.baseUrl}${ApiConst.loginMpinApi}",
      body: body,
      header: headers,
    );
    log("Login MPIN Response: $response");

    return AuthModel.fromJson(response);
  }

  /// Forgot Password OTP Repo
  static Future<AuthModel> forgotPasswordOtp(Map<String, dynamic> body) async {
    var response = await ApiService().getResponse(
      apiType: APIType.aPost,
      url: "${ApiConst.baseUrl}${ApiConst.forgotPasswordOtpApi}",
      body: body,
    );
    log("Forgot Password OTP Response: $response");

    return AuthModel.fromJson(response);
  }

  /// Reset Password OTP Repo
  // static Future<AuthModel> resetPasswordOtp(Map<String, dynamic> body) async {
  //   var response = await ApiService().getResponse(
  //     apiType: APIType.aPost,
  //     // url: "${ApiConst.baseUrl}${ApiConst.resetPasswordOtpApi}",
  //     url: "${ApiConst.baseUrl}${ApiConst.resetPasswordOtpAlternativeApi}",
  //     body: body,
  //   );
  //   log("Reset Password OTP Response: $response");
  //
  //   return AuthModel.fromJson(response);
  // }

  /// Forgot MPIN OTP Repo
  static Future<AuthModel> forgotMpinOtp(Map<String, dynamic> body) async {
    var response = await ApiService().getResponse(
      apiType: APIType.aPost,
      url: "${ApiConst.baseUrl}${ApiConst.forgotMpinOtpApi}",
      body: body,
    );
    log("Forgot MPIN OTP Response: $response");

    return AuthModel.fromJson(response);
  }

  /// Reset MPIN OTP Repo
  static Future<AuthModel> resetMpinOtp(Map<String, dynamic> body) async {
    var response = await ApiService().getResponse(
      apiType: APIType.aPost,
      url: "${ApiConst.baseUrl}${ApiConst.resetMpinOtpApi}",
      body: body,
    );
    log("Reset MPIN OTP Response: $response");

    return AuthModel.fromJson(response);
  }

  /// Set Password Repo
  static Future<AuthModel> setPassword(Map<String, dynamic> body) async {
    var response = await ApiService().getResponse(
      apiType: APIType.aPost,
      url: "${ApiConst.baseUrl}${ApiConst.setPasswordApi}",
      body: body,
    );
    log("Set Password Response: $response");

    return AuthModel.fromJson(response);
  }
}

