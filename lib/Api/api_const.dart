class ApiConst {
  // static const String baseUrl = "http://192.168.1.66:5000";
  static const String baseUrl = "https://miner-3np7.onrender.com/api";
  static const String socketUrl = "https://miner-3np7.onrender.com";

  static const String registerApi = "/auth/register";
  static const String googleApi = "/auth/google"; // done
  static const String firebaseLoginApi = "/auth/firebase-login";
  static const String refreshTokenApi = "/auth/refresh-token";
  static const String logoutApi = "/auth/logout"; // done
  static const String changePasswordApi = "/auth/change-password"; // done
  static const String meApi = "/auth/me"; // done
  static const String setPasswordApi = "/auth/set-password";
  static const String dashboardApi = "/user/dashboard";

  /// Mining APIs
  static const String adTokenApi =
      "/mining/ad-token"; // 00:00:00 replace to START MINING SESSION /// done
  static const String startMiningApi = "/mining/start"; // done
  static const String stopMiningApi = "/mining/stop"; // done
  static const String miningStatusApi = "/mining/status"; // done
  static const String miningHistoryApi = "/mining/history"; // done

  /// Wallet APIs
  static const String walletBalanceApi = "/wallet/balance"; // done
  static const String walletTransactionsApi = "/wallet/transactions"; // done

  /// Withdrawals APIs
  static const String withdrawalsRequestApi = "/withdrawals/request";
  static const String withdrawalsHistoryApi = "/withdrawals/history"; // done

  /// Subscription & Premium APIs
  static const String SubscriptionPlanApi = "/subscriptions/plans"; // done =
  static const String SubscriptionPlanPurchaseApi = "/subscriptions/purchase";
  static const String CurrentSubscriptionPlanApi =
      "/subscriptions/current"; // done =
  static const String AllSubscriptionPlanHistoryApi =
      "/subscriptions/history"; // done

  /// Referral APIs
  static const String ReferralsInfoApi = "/referrals/info"; // done
  static const String ReferralsUserApi = "/referrals/users"; // done
  static const String ReferralsRewardsApi = "/referrals/rewards"; // done

  /// Mpin & Auth OTP APIs
  static const String createMpinApi = "/auth/create-mpin";
  static const String setMpinApi = "/auth/set-mpin"; // done
  static const String loginMpinApi = "/auth/login-mpin"; // done
  static const String forgotPasswordOtpApi = "/auth/forgot-password-otp"; // done
  static const String resetPasswordOtpApi = "/auth/reset-password-otp"; // done
  static const String forgotMpinOtpApi = "/auth/forgot-mpin-otp"; // done
  static const String resetMpinOtpApi = "/auth/reset-mpin-otp"; // done
  // aene ss moklu ruko e mage che aek to var lage che aama forgot PIn thata

  // static const String verifyMpinApi = "/auth/verify-mpin";
  // static const String changeMpinApi = "/auth/change-mpin";

  static const String updateProfileApi = "/auth/update-profile";

  /// Notification APIs
  static const String notificationApi = "/notifications"; // done
  static const String notificationUnreadCountApi =
      "/notifications/unread-count"; // done
  static const String notificationReadAllApi =
      "/notifications/read-all"; // done
  static String notificationReadApi(String id) =>
      "/notifications/$id/read"; // done
  static String notificationDeleteApi(String id) =>
      "/notifications/$id"; // done
}
