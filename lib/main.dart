import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'Auth/login_screen.dart';
import 'Auth/auth_binding.dart';
import 'Service/storage_service.dart';
import 'Service/notification_service.dart';
import 'Service/background_notification_handler.dart';

import 'Auth/mpin_unlock_screen.dart';
import 'Features/Home/home_screen.dart';
import 'Features/Onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences first
  try {
    await SharedPrefHelper.init();
  } catch (e) {
    debugPrint("SharedPrefHelper initialization failed: $e");
  }

  // Initialize Mobile Ads
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint("MobileAds initialization failed: $e");
  }

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  // Initialize Notification Service
  try {
    Get.put(NotificationService());
    await NotificationService.to.init();
  } catch (e) {
    debugPrint("NotificationService initialization failed: $e");
  }

  final String? token = SharedPrefHelper.getString("token");
  final bool hasMpin = SharedPrefHelper.getBool("hasMpin") ?? false;
  final bool hasSeenOnboarding = SharedPrefHelper.getBool("hasSeenOnboarding") ?? false;
  runApp(MyApp(
    isLoggedIn: token != null && token.isNotEmpty,
    hasMpin: hasMpin,
    hasSeenOnboarding: hasSeenOnboarding,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool hasMpin;
  final bool hasSeenOnboarding;
  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.hasMpin,
    required this.hasSeenOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: AuthBinding(),
      theme: ThemeData(fontFamily: 'Poppins'),
      home: isLoggedIn
          ? (hasMpin ? const MpinUnlockScreen() : const HomeScreenView())
          : (hasSeenOnboarding ? const LoginScreenView() : const OnboardingScreenView()),
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

/// static data
// 1>> My Miner screen => Free tab => my_miner_screen => Speed CPU Power(100 Th/s), Estimate Profit, Expires on, Free
// 2>> Create Minor => Select CPU data hardcode [cpuOptions]
// 3>> join_referral_bottom_sheet in Continue button API

/// auto login update code
// AndroidManifest.xml file

// chat gpt temp mail :-- goyox60719@fivejm.com

/// ads
/// native & banner ads ===> app_banner & duolingo_banner & interstitial ads
// figma ma je green ads che ae badhi banner ads chhe je static aavshe & native ads chhe ae custom aavshe
// bottom ads che navigation ni upar ae banner ads che je full width ma avshe [all common]
// top ma ads che ae native ads and ae custom avshe
// password change and mpin change pchi je ads avshe ae industrial ads avshe
// Banner and native ads & banner ads no use schrolling mate no thay & password ane mpin change krine industrial ads
// interstitial ads ==> apply in after change password & after MPIN change
/// dismiss ads dialog close screen changes comment name below...
// <!-- Disable AdMob Native Ad Validator -->
// info.plist file :- GADNativeAdValidatorEnabled & niche ni line add kri false

/// Scan
// referral 1 time scan & invite multiple time scan

// auto logout code in i comment // auto logout
// file name :- api_handler & socket_service

// feature audit
// run analysis
// screen audit
// implementation details

// Digital@803h

// boost => ads puri thay aetle MiningRepo.getAdToken() aa api call thay chhe [[[ key :- baseMiningSpeed: 1.2 ]]]
// after API success return fetchMiningStatus() [socket mathi] & fetchDashboardData() [dashboard api mathi] farithi call klariae chiae
// final speed = statusData['miningSpeed'] ?? statusData['session']?['miningSpeed'] ?? socketService.currentSpeed.value;


// ⏱️ [LOCAL TIMER] Live Count ticking:
// 🔵 [API SYNC] Live Count fetched as:
// 🟢 [SOCKET SYNC] Live Count updated to:

// 1 => 1st changes
// 1 => 2nd changes => done
// 2 => 1st changes => done
// 2 => 2nd changes => done
// 3 => 1st changes
// 3 => 2nd changes
// 3 => erd changes

// body: {"adCompleted": adCompleted}, ==> comment of mining start button error

/// home screen after open MPIN screen /// screen navigation issue comment

// r

// log
// Saved new Google user to Firestore.
// Updated existing Google user in Firestore
// Error writing Google user details to Firestore

// comment \\
// Mining account issue
// mining digits issue
// mining speed issue
// Entered WalletScreen - Current Total Balance
// Claim Wallet Response

/// HOUR MIN SESSION