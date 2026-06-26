import 'dart:convert';
import 'dart:developer';
import 'dart:async';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'api_response.dart';
import 'api_const.dart';
import '../Service/storage_service.dart';
import '../Auth/auth_model.dart';
import '../Auth/auth_controller.dart';

enum APIType { aGet, aPost, aImageForm, aPut, aPatch, aDelete }

class ApiService {
  static final dio.Dio dioClient = dio.Dio(
    dio.BaseOptions(
      validateStatus: (status) => status != null && status < 600,
    ),
  )..interceptors.add(TokenRefreshInterceptor());

  dynamic response;

  Future<dynamic> getResponse({
    required APIType apiType,
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? header,
  }) async {
    response = null;
    final options = dio.Options(headers: header);
    try {
      if (apiType == APIType.aGet) {
        // GET request
        final result = await dioClient.get(url, options: options);
        log("Response URL: $url");
        log("Status Code: ${result.statusCode}");
        log("Response Data: ${result.data}");
        if (result.data is String) {
          response = returnResponse(result.statusCode!, result.data);
        } else {
          response = returnResponse(result.statusCode!, jsonEncode(result.data));
        }
      } else if (apiType == APIType.aPost) {
        // POST request
        log("Sending POST to $url");
        log("Headers: $header");
        log("Body: $body");
        final result = await dioClient.post(
          url,
          data: body,
          options: options,
        );
        log("Response URL:: $url");
        log("status Code:: ${result.statusCode}");
        log("Response Data:: ${result.data}");
        if (result.data is String) {
          response = returnResponse(result.statusCode!, result.data);
        } else {
          response = returnResponse(result.statusCode!, jsonEncode(result.data));
        }
      } else if (apiType == APIType.aImageForm) {
        // Image/Form request
        final formData = dio.FormData.fromMap(body!);
        final result = await dioClient.post(
          url,
          data: formData,
          options: options,
        );
        log("Response URL::: $url");
        log("Status Code::: ${result.statusCode}");
        log("Response Data::: ${result.data}");
        if (result.data is String) {
          response = returnResponse(result.statusCode!, result.data);
        } else {
          response = returnResponse(result.statusCode!, jsonEncode(result.data));
        }
      } else if (apiType == APIType.aPut) {
        // PUT request
        log("Sending PUT to $url");
        log("Headers: $header");
        log("Body: $body");
        final result = await dioClient.put(
          url,
          data: body,
          options: options,
        );
        log("Response URL:: $url");
        log("status Code:: ${result.statusCode}");
        log("Response Data:: ${result.data}");
        if (result.data is String) {
          response = returnResponse(result.statusCode!, result.data);
        } else {
          response = returnResponse(result.statusCode!, jsonEncode(result.data));
        }
      } else if (apiType == APIType.aPatch) {
        // PATCH request
        log("Sending PATCH to $url");
        log("Headers: $header");
        log("Body: $body");
        final result = await dioClient.patch(
          url,
          data: body,
          options: options,
        );
        log("Response URL:: $url");
        log("status Code:: ${result.statusCode}");
        log("Response Data:: ${result.data}");
        if (result.data is String) {
          response = returnResponse(result.statusCode!, result.data);
        } else {
          response = returnResponse(result.statusCode!, jsonEncode(result.data));
        }
      } else if (apiType == APIType.aDelete) {
        // DELETE request
        log("Sending DELETE to $url");
        log("Headers: $header");
        final result = await dioClient.delete(
          url,
          data: body,
          options: options,
        );
        log("Response URL:: $url");
        log("status Code:: ${result.statusCode}");
        log("Response Data:: ${result.data}");
        if (result.data is String) {
          response = returnResponse(result.statusCode!, result.data);
        } else {
          response = returnResponse(result.statusCode!, jsonEncode(result.data));
        }
      }
    } catch (error) {
      if (error is dio.DioException) {
        // Dio-specific error handling
        log("DioError Response: ${error.response?.data ?? error.message}");
        ApiResponse.error(message: error.message);
      } else {
        log("Unknown Error: $error");
        ApiResponse.error(message: error.toString());
      }
      log("ERROR====>[$error]");
    }
    return response;
  }

  dynamic returnResponse(int status, String result) {
    try {
      return jsonDecode(result);
    } catch (e) {
      return {"success": false, "message": result};
    }
  }
}

class TokenRefreshInterceptor extends dio.Interceptor {
  bool _isRefreshing = false;
  final List<Map<String, dynamic>> _failedRequestsQueue = [];

  @override
  void onRequest(
    dio.RequestOptions options,
    dio.RequestInterceptorHandler handler,
  ) {
    final String? token = SharedPrefHelper.getString("token");
    if (token != null && token.isNotEmpty && !options.headers.containsKey("Authorization")) {
      options.headers["Authorization"] = "Bearer $token";
    }
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    dio.Response response,
    dio.ResponseInterceptorHandler handler,
  ) async {
    final int statusCode = response.statusCode ?? 0;
    final String requestPath = response.requestOptions.path;

    // Check if the response is 401 and it's not the refresh token request itself
    if (statusCode == 401 && !requestPath.contains("/auth/refresh-token")) {
      log("🔑 TokenRefreshInterceptor: 401 Unauthorized encountered on $requestPath");

      if (!_isRefreshing) {
        _isRefreshing = true;

        try {
          final String? refreshToken = SharedPrefHelper.getString("refreshToken");
          if (refreshToken == null || refreshToken.isEmpty) {
            log("🔑 TokenRefreshInterceptor: No refresh token found. Logging out user.");
            _handleLogout();
            handler.next(response);
            return;
          }

          log("🔑 TokenRefreshInterceptor: Triggering token refresh api...");
          // Call the refresh token endpoint using a separate Dio instance to avoid interceptor recursion
          final refreshDio = dio.Dio();
          refreshDio.options.validateStatus = (status) => status != null && status < 600;
          
          final refreshResult = await refreshDio.post(
            "${ApiConst.baseUrl}${ApiConst.refreshTokenApi}",
            data: {
              "refreshToken": refreshToken,
              "token": refreshToken, // safe fallback for other key naming styles
            },
          );

          log("🔑 TokenRefreshInterceptor: Refresh token api response: ${refreshResult.statusCode} - ${refreshResult.data}");

          if (refreshResult.statusCode == 200 || refreshResult.statusCode == 201) {
            final Map<String, dynamic> data = refreshResult.data is String 
                ? jsonDecode(refreshResult.data) 
                : refreshResult.data;
            final AuthModel authModel = AuthModel.fromJson(data);

            final String? newAccessToken = authModel.data?.token;
            final String? newRefreshToken = authModel.data?.refreshToken;

            if (newAccessToken != null && newAccessToken.isNotEmpty) {
              log("🔑 TokenRefreshInterceptor: Token refreshed successfully.");
              await SharedPrefHelper.setString("token", newAccessToken);
              if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
                await SharedPrefHelper.setString("refreshToken", newRefreshToken);
              }

              // Update the current request header and retry it
              response.requestOptions.headers["Authorization"] = "Bearer $newAccessToken";
              
              // Retry the original request
              final retryResponse = await ApiService.dioClient.request(
                response.requestOptions.path,
                options: dio.Options(
                  method: response.requestOptions.method,
                  headers: response.requestOptions.headers,
                ),
                data: response.requestOptions.data,
                queryParameters: response.requestOptions.queryParameters,
              );

              // Resolve the current handler with the retried response
              handler.resolve(retryResponse);

              // Process queued requests
              for (var queuedRequest in _failedRequestsQueue) {
                final requestOptions = queuedRequest['options'] as dio.RequestOptions;
                final completer = queuedRequest['completer'] as Completer<dio.Response>;

                requestOptions.headers["Authorization"] = "Bearer $newAccessToken";
                
                try {
                  final queuedResponse = await ApiService.dioClient.request(
                    requestOptions.path,
                    options: dio.Options(
                      method: requestOptions.method,
                      headers: requestOptions.headers,
                    ),
                    data: requestOptions.data,
                    queryParameters: requestOptions.queryParameters,
                  );
                  completer.complete(queuedResponse);
                } catch (e) {
                  completer.completeError(e);
                }
              }
              _failedRequestsQueue.clear();
              return;
            }
          }

          // If we reach here, refresh failed
          log("🔑 TokenRefreshInterceptor: Refresh token api failed. Logging out user.");
          _handleLogout();
          handler.next(response);
        } catch (e) {
          log("🔑 TokenRefreshInterceptor: Error during token refresh: $e");
          _handleLogout();
          handler.next(response);
        } finally {
          _isRefreshing = false;
        }
      } else {
        // If already refreshing, queue this request
        log("🔑 TokenRefreshInterceptor: Refresh already in progress. Queueing request: $requestPath");
        final completer = Completer<dio.Response>();
        _failedRequestsQueue.add({
          'options': response.requestOptions,
          'completer': completer,
        });

        try {
          final retriedResponse = await completer.future;
          handler.resolve(retriedResponse);
        } catch (e) {
          // If retrying fails, pass original response
          handler.next(response);
        }
      }
      return;
    }

    // Normal response path
    handler.next(response);
  }

  void _handleLogout() {
    if (Get.isRegistered<AuthController>()) {
      Get.find<AuthController>().logout();
    } else {
      SharedPrefHelper.remove("token");
      SharedPrefHelper.remove("refreshToken");
      SharedPrefHelper.remove("userId");
      SharedPrefHelper.remove("email");
      SharedPrefHelper.remove("name");
      SharedPrefHelper.remove("hasMpin");
    }
  }
}
