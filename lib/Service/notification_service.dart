import 'dart:developer' as dev;
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
import 'package:flutter/material.dart';
import '../Utility/common_color.dart';


class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  Future<NotificationService> init() async {
    print("NotificationService: init() started");
    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      print("NotificationService: Timezone initialized successfully");
    } catch (e) {
      print("⚠️ Timezone localization error: $e");
    }

    try {
      await _initLocalNotifications();
      print("NotificationService: Local Notifications initialized successfully");
    } catch (e) {
      print("⚠️ Local Notifications initialization error: $e");
    }

    try {
      await _initFcm();
      print("NotificationService: FCM initialized successfully");
    } catch (e) {
      print("⚠️ FCM initialization error: $e");
    }

    final String? token = SharedPrefHelper.getString("token");
    if (token != null && token.isNotEmpty) {
      try {
        fetchUnreadCount();
        fetchNotifications();
        uploadFcmToken();
      } catch (e) {
        print("⚠️ Error during initial notification fetch/upload: $e");
      }
    }
    print("NotificationService: init() completed successfully");
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
        "deviceId": fcmToken,
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

    // Create notification channels for Android immediately on startup
    if (GetPlatform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        try {
          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              'mining_channel',
              'Mining Notifications',
              description: 'Notifications related to mining sessions',
              importance: Importance.max,
              playSound: true,
            ),
          );
          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              'mining_completed_channel',
              'Mining Completion',
              description: 'Triggered when mining session finishes',
              importance: Importance.max,
              playSound: true,
            ),
          );
          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              'instant_notifications_channel',
              'Instant Notifications',
              description: 'Triggered for instant app events like starting mining',
              importance: Importance.max,
              playSound: true,
            ),
          );
          dev.log("Notification channels created successfully.");
        } catch (e) {
          dev.log("⚠️ Error creating notification channels: $e");
        }
      }
    }
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
    print("Scheduling local notification in $durationSeconds seconds...");
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

    // Cancel any existing scheduled notifications to prevent duplicates
    await _localNotifications.cancel(999);
    await _localNotifications.cancel(998);

    try {
      final scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(seconds: durationSeconds));
      print("Scheduling exact notification at: $scheduledTime (location: ${tz.local.name})");
      await _localNotifications.zonedSchedule(
        999,
        'Your mining session is complete!',
        "Don't miss out on today's rewards. Start your new mining session now and continue mining without interruption.",
        scheduledTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      print("ℹ️ Scheduled exact notification successfully.");
    } catch (e) {
      print("⚠️ Error scheduling exact local notification: $e. Trying inexact fallback...");
      try {
        final scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(seconds: durationSeconds));
        await _localNotifications.zonedSchedule(
          999,
          'Your mining session is complete!',
          "Don't miss out on today's rewards. Start your new mining session now and continue mining without interruption.",
          scheduledTime,
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
        print("ℹ️ Scheduled inexact notification successfully as fallback.");
      } catch (ex) {
        print("⚠️ Inexact fallback failed: $ex");
      }
    }

    // Schedule 12-hour notification if duration is longer than 12 hours (43200 seconds)
    if (durationSeconds > 43200) {
      try {
        await _localNotifications.zonedSchedule(
          998,
          'Mining Session Update',
          '12 hours of your mining session have completed successfully!',
          tz.TZDateTime.now(tz.local).add(const Duration(hours: 12)),
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
        print("ℹ️ Scheduled 12-hour completion notification successfully.");
      } catch (e) {
        print("⚠️ Error scheduling 12-hour notification: $e. Trying inexact fallback...");
        try {
          await _localNotifications.zonedSchedule(
            998,
            'Mining Session Update',
            '12 hours of your mining session have completed successfully!',
            tz.TZDateTime.now(tz.local).add(const Duration(hours: 12)),
            platformChannelSpecifics,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          );
          print("ℹ️ Scheduled inexact 12-hour completion notification successfully.");
        } catch (ex) {
          print("⚠️ 12-hour fallback failed: $ex");
        }
      }
    }
  }

  Future<void> cancelMiningCompletionNotification() async {
    dev.log("Cancelling scheduled mining notification...");
    await _localNotifications.cancel(999);
    await _localNotifications.cancel(998);
  }

  Future<void> showInstantNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'instant_notifications_channel',
      'Instant Notifications',
      channelDescription: 'Triggered for instant app events like starting mining',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      platformChannelSpecifics,
    );
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

  /// Check if exact alarm permission is granted (Android 13/14+)
  Future<bool> isExactAlarmPermissionGranted() async {
    if (!GetPlatform.isAndroid) return true;
    try {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final bool? isGranted = await androidPlugin?.canScheduleExactNotifications();
      return isGranted ?? false;
    } catch (e) {
      dev.log("Error checking exact alarm permission: $e");
      return false;
    }
  }

  /// Request exact alarm permission (takes user to system settings on Android 13/14+)
  Future<bool> requestExactAlarmPermission() async {
    if (!GetPlatform.isAndroid) return true;
    try {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final bool? isGranted = await androidPlugin?.requestExactAlarmsPermission();
      return isGranted ?? false;
    } catch (e) {
      dev.log("Error requesting exact alarm permission: $e");
      return false;
    }
  }

  /// Request exact alarm permission with a descriptive dialog explaining why it's needed
  Future<void> checkAndRequestExactAlarms() async {
    if (!GetPlatform.isAndroid) return;

    final isGranted = await isExactAlarmPermissionGranted();
    if (!isGranted) {
      // Check if we already prompted the user
      final bool alreadyPrompted = SharedPrefHelper.getBool("prompted_exact_alarm") ?? false;
      if (!alreadyPrompted) {
        await Get.dialog(
          ExactAlarmPermissionDialog(
            onConfirm: () async {
              Get.back(); // close dialog
              await SharedPrefHelper.setBool("prompted_exact_alarm", true);
              await requestExactAlarmPermission();
            },
            onCancel: () async {
              Get.back(); // close dialog
              await SharedPrefHelper.setBool("prompted_exact_alarm", true);
            },
          ),
          barrierDismissible: false,
        );
      }
    }
  }
}

class ExactAlarmPermissionDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ExactAlarmPermissionDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: CommonColor.greyCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CommonColor.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.alarm_on_rounded,
                color: CommonColor.blue,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Alarms & Reminders Permission",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              "To receive notifications exactly when your mining session completes—even when the app is completely closed—please grant the 'Alarms & Reminders' permission in settings.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CommonColor.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Settings",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
