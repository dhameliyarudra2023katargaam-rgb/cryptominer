import 'dart:developer' as dev;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../Model/notification_model.dart';
import '../Repo/notification_repo.dart';
import '../Repo/auth_repo.dart';
import '../Features/Notification/notification_screen.dart';
import 'storage_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  dev.log("Handling a background message: ${message.messageId}");
}

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  Future<NotificationService> init() async {
    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    } catch (e) {
      dev.log("⚠️ Timezone localization error: $e");
    }
    await _initLocalNotifications();
    await _initFcm();

    final String? token = SharedPrefHelper.getString("token");
    if (token != null && token.isNotEmpty) {
      fetchUnreadCount();
      fetchNotifications();
      uploadFcmToken();
    }
    return this;
  }

  Future<void> uploadFcmToken() async {
    final String? sessionToken = SharedPrefHelper.getString("token");
    if (sessionToken == null || sessionToken.isEmpty) return;

    final String? fcmToken = SharedPrefHelper.getString("fcmToken");
    if (fcmToken == null || fcmToken.isEmpty) return;

    try {
      dev.log("Uploading FCM Token to backend...");
      final response = await AuthRepo.updateProfile({
        "fcmToken": fcmToken,
        "deviceToken": fcmToken,
      });
      dev.log("FCM Token upload response success: ${response.isSuccess}, message: ${response.message}");
    } catch (e) {
      dev.log("Failed to upload FCM Token: $e");
    }
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        dev.log("Notification tapped: ${response.payload}");
        Get.to(() => const NotificationScreen());
      },
    );
  }

  Future<void> _initFcm() async {
    // Request permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      dev.log('User granted permission');
    } else {
      dev.log('User declined or has not accepted permission');
    }

    // Get Token
    String? token = await _fcm.getToken();
    dev.log("FCM TOKEN: $token");
    if (token != null) {
      await SharedPrefHelper.setString("fcmToken", token);
      uploadFcmToken();
    }

    // Listen for token updates
    _fcm.onTokenRefresh.listen((newToken) {
      dev.log("FCM TOKEN REFRESHED: $newToken");
      SharedPrefHelper.setString("fcmToken", newToken);
      uploadFcmToken();
    });

    // Foreground listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      dev.log("Foreground FCM message received: ${message.notification?.title}");
      _showForegroundNotification(message);
      fetchUnreadCount();
      fetchNotifications();
    });

    // Opened app from notification listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      dev.log("FCM notification opened app: ${message.data}");
      Get.to(() => const NotificationScreen());
    });

    // Terminated state app launch from notification
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        dev.log("FCM initial message received: ${message.data}");
        Future.delayed(const Duration(seconds: 1), () {
          Get.to(() => const NotificationScreen());
        });
      }
    });
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'mining_channel',
        'Mining Notifications',
        channelDescription: 'Notifications related to mining sessions',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      final String? originalBody = notification.body;
      final String? rewardAmount = message.data['rewardAmount'];

      String? formattedBody;
      if (rewardAmount != null && rewardAmount.isNotEmpty) {
        formattedBody = "Reward $rewardAmount BTC";
      } else {
        formattedBody = originalBody?.replaceAll(RegExp(r'[Yy]ou earned'), 'Reward');
      }

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        formattedBody,
        platformChannelSpecifics,
        payload: message.data.toString(),
      );
    }
  }

  /// Schedule a notification for when mining ends
  Future<void> scheduleMiningCompletionNotification(int durationSeconds) async {
    dev.log("Scheduling local notification in $durationSeconds seconds...");
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'mining_completed_channel',
      'Mining Completion',
      channelDescription: 'Triggered when mining session finishes',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Cancel any existing scheduled notification with ID 999 to prevent duplicates
    await _localNotifications.cancel(999);

    try {
      await _localNotifications.zonedSchedule(
        999,
        'Your mining session is complete!',
        "Don't miss out on today's rewards. Start your new mining session now and continue mining without interruption.",
        tz.TZDateTime.now(tz.local).add(Duration(seconds: durationSeconds)),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      dev.log("ℹ️ Scheduled exact notification successfully.");
    } catch (e) {
      dev.log("⚠️ Error scheduling exact local notification: $e. Trying inexact fallback...");
      try {
        await _localNotifications.zonedSchedule(
          999,
          'Your mining session is complete!',
          "Don't miss out on today's rewards. Start your new mining session now and continue mining without interruption.",
          tz.TZDateTime.now(tz.local).add(Duration(seconds: durationSeconds)),
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
        dev.log("ℹ️ Scheduled inexact notification successfully as fallback.");
      } catch (ex) {
        dev.log("⚠️ Inexact fallback failed: $ex");
      }
    }
  }

  Future<void> cancelMiningCompletionNotification() async {
    dev.log("Cancelling scheduled mining notification...");
    await _localNotifications.cancel(999);
  }

  // --- API CALLS ---

  Future<void> fetchNotifications() async {
    final String? token = SharedPrefHelper.getString("token");
    if (token == null || token.isEmpty) return;

    try {
      isLoading.value = true;
      final response = await NotificationRepo.getNotifications();

      if (response != null && response.success) {
        notifications.value = response.data;
      }
    } catch (e) {
      dev.log("Error fetching notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUnreadCount() async {
    final String? token = SharedPrefHelper.getString("token");
    if (token == null || token.isEmpty) return;

    try {
      final response = await NotificationRepo.getUnreadCount();

      if (response != null && response.success) {
        unreadCount.value = response.unreadCount;
      }
    } catch (e) {
      dev.log("Error fetching unread count: $e");
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await NotificationRepo.markAllAsRead();

      if (response != null && response.success) {
        unreadCount.value = 0;
        await fetchNotifications();
      }
    } catch (e) {
      dev.log("Error marking all read: $e");
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final response = await NotificationRepo.markAsRead(id);

      if (response != null && response.success) {
        await fetchUnreadCount();
        await fetchNotifications();
      }
    } catch (e) {
      dev.log("Error marking read: $e");
    }
  }

  Future<void> deleteNotification(String id) async {
    // Synchronously remove from the local state list to avoid tree mismatch during Dismissible swipe
    notifications.removeWhere((notification) => notification.id == id);

    try {
      final response = await NotificationRepo.deleteNotification(id);

      if (response != null && response.success) {
        await fetchUnreadCount();
        await fetchNotifications();
      } else {
        // Fallback: reload from backend if deletion failed
        await fetchNotifications();
      }
    } catch (e) {
      dev.log("Error deleting notification: $e");
      await fetchNotifications();
    }
  }
}
