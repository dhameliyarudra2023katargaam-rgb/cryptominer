import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'Auth/login_screen.dart';
import 'Auth/auth_binding.dart';
import 'Service/storage_service.dart';
import 'Service/notification_service.dart';

import 'Auth/mpin_unlock_screen.dart';
import 'Features/Home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await SharedPrefHelper.init();
  Get.put(NotificationService());
  await NotificationService.to.init();
  final String? token = SharedPrefHelper.getString("token");
  final bool hasMpin = SharedPrefHelper.getBool("hasMpin") ?? false;
  runApp(MyApp(
    isLoggedIn: token != null && token.isNotEmpty,
    hasMpin: hasMpin,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool hasMpin;
  const MyApp({super.key, required this.isLoggedIn, required this.hasMpin});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: AuthBinding(),
      theme: ThemeData(fontFamily: 'Gayathri'),
      home: isLoggedIn
          ? (hasMpin ? const MpinUnlockScreen() : const HomeScreenView())
          : const LoginScreenView(),
    );
  }
}
// http://192.168.1.69:5000/

// android client id :-
// Android Debug Key: 715037403897-...

// web client id :-
// Web Client: 715037403897-i9g4411320geq9gfnj8k6oa8bp44oevp.apps.googleusercontent.com
// timeout(const Duration(seconds

/// socket data home screen
/// BTC, BTC Mined, mining speed(0.0 MH/s), countdown timer

/// Continue with login [use API]
/// google_sign_in use this package & use API
/// login JWT token store in share preference
/// after login process like all apis and logout api store as a Bearer token

// socket implement
// Socket connect/disconnect
// mining:status listen
// Mining data handle (balance, speed, remainingTime)
// Auto-stop, local timer

// not implement
// mining:subscribe - Connect thaya pachi subscribe emit karvy joiae pan hal wrong events emit thay che

// new user => create (set) => api server ma padi gyo => logout after login => app clear sharepreference clear original ma set che



// hi
// hello
//