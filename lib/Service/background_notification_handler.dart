import 'dart:developer' as dev;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    dev.log("⚠️ Error initializing Firebase in background handler: $e");
  }
  
  dev.log("Handling a background message: ${message.messageId}");

  // Write log for debugging background delivery
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> logs = prefs.getStringList("bg_notification_logs") ?? [];
    logs.add("${DateTime.now().toIso8601String()}: Received message ID ${message.messageId}");
    await prefs.setStringList("bg_notification_logs", logs);
  } catch (e) {
    dev.log("⚠️ Failed to write background log: $e");
  }

  // Only show manual notification if the message does not have a notification block (data-only message)
  // to avoid showing duplicate notifications on Android.
  if (message.notification == null && message.data.isNotEmpty) {
    final title = message.data['title'] ?? 'Mining Update';
    final body = message.data['body'] ?? message.data['message'] ?? '';
    final rewardAmount = message.data['rewardAmount'];

    String formattedBody = body;
    if (rewardAmount != null && rewardAmount.toString().isNotEmpty) {
      formattedBody = "Reward $rewardAmount BTC";
    } else {
      formattedBody = body.replaceAll(RegExp(r'[Yy]ou earned'), 'Reward');
    }

    try {
      final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );
      await localNotifications.initialize(initializationSettings);

      // Create the notification channel to ensure it exists
      final androidPlugin = localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'mining_channel',
            'Mining Notifications',
            description: 'Notifications related to mining sessions',
            importance: Importance.max,
            playSound: true,
          ),
        );
      }

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'mining_channel',
        'Mining Notifications',
        channelDescription: 'Notifications related to mining sessions',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await localNotifications.show(
        message.hashCode,
        title,
        formattedBody,
        platformChannelSpecifics,
        payload: message.data.toString(),
      );
      dev.log("✅ Successfully showed background notification.");
    } catch (e) {
      dev.log("⚠️ Error showing background notification: $e");
    }
  }
}
