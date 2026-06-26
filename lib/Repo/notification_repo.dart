import 'dart:developer' as dev;
import '../Api/api_const.dart';
import '../Api/api_handler.dart';
import '../Service/storage_service.dart';
import '../Model/notification_model.dart';

class NotificationRepo {
  static Map<String, String> _getHeaders() {
    final String? token = SharedPrefHelper.getString("token");
    return token != null && token.isNotEmpty
        ? {"Authorization": "Bearer $token"}
        : {};
  }

  /// Get all notifications
  static Future<NotificationListResponse?> getNotifications() async {
    try {
      final response = await ApiService().getResponse(
        apiType: APIType.aGet,
        url: "${ApiConst.baseUrl}${ApiConst.notificationApi}",
        header: _getHeaders(),
      );
      dev.log("Get Notifications Response: $response");
      if (response is Map<String, dynamic>) {
        return NotificationListResponse.fromJson(response);
      }
    } catch (e) {
      dev.log("Error in getNotifications repo: $e");
    }
    return null;
  }

  /// Get unread count
  static Future<UnreadCountResponse?> getUnreadCount() async {
    try {
      final response = await ApiService().getResponse(
        apiType: APIType.aGet,
        url: "${ApiConst.baseUrl}${ApiConst.notificationUnreadCountApi}",
        header: _getHeaders(),
      );
      dev.log("Get Unread Count Response: $response");
      if (response is Map<String, dynamic>) {
        return UnreadCountResponse.fromJson(response);
      }
    } catch (e) {
      dev.log("Error in getUnreadCount repo: $e");
    }
    return null;
  }

  /// Mark all as read
  static Future<NotificationActionResponse?> markAllAsRead() async {
    try {
      final response = await ApiService().getResponse(
        apiType: APIType.aPatch,
        url: "${ApiConst.baseUrl}${ApiConst.notificationReadAllApi}",
        header: _getHeaders(),
      );
      dev.log("Mark All As Read Response: $response");
      if (response is Map<String, dynamic>) {
        return NotificationActionResponse.fromJson(response);
      }
    } catch (e) {
      dev.log("Error in markAllAsRead repo: $e");
    }
    return null;
  }

  /// Mark a specific notification as read
  static Future<NotificationActionResponse?> markAsRead(String id) async {
    try {
      final response = await ApiService().getResponse(
        apiType: APIType.aPatch,
        url: "${ApiConst.baseUrl}${ApiConst.notificationReadApi(id)}",
        header: _getHeaders(),
      );
      dev.log("Mark As Read Response: $response");
      if (response is Map<String, dynamic>) {
        return NotificationActionResponse.fromJson(response);
      }
    } catch (e) {
      dev.log("Error in markAsRead repo: $e");
    }
    return null;
  }

  /// Delete a notification
  static Future<NotificationActionResponse?> deleteNotification(String id) async {
    try {
      final response = await ApiService().getResponse(
        apiType: APIType.aDelete,
        url: "${ApiConst.baseUrl}${ApiConst.notificationDeleteApi(id)}",
        header: _getHeaders(),
      );
      dev.log("Delete Notification Response: $response");
      if (response is Map<String, dynamic>) {
        return NotificationActionResponse.fromJson(response);
      }
    } catch (e) {
      dev.log("Error in deleteNotification repo: $e");
    }
    return null;
  }
}
