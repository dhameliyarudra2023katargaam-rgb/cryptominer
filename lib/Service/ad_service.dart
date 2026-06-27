import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService instance = AdService._();
  AdService._();

  bool _isAdLoadingOrShowing = false;

  /// Load and show ad, returns true if ad was completed successfully, or false if failed.
  Future<bool> showAd({required String adType, required bool retryOnFailure}) async {
    if (_isAdLoadingOrShowing) {
      dev.log("🚫 AdService: An ad is already loading or showing.");
      return false;
    }
    _isAdLoadingOrShowing = true;

    try {
      Future<bool> adFuture;
      if (adType.toLowerCase() == 'interstitial') {
        adFuture = _showInterstitialAd(retryOnFailure);
      } else {
        // Default to rewarded ad
        adFuture = _showRewardedAd(retryOnFailure);
      }

      // Timeout loading after 8 seconds to prevent hanging
      return await adFuture.timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          dev.log("⏰ AdService: Ad loading timed out.");
          return false;
        },
      );
    } catch (e) {
      dev.log("❌ AdService Error showing ad: $e");
      return false;
    } finally {
      _isAdLoadingOrShowing = false;
    }
  }

  Future<bool> _showRewardedAd(bool retryOnFailure) async {
    final completer = Completer<bool>();
    final adUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/5224354917' // Android Rewarded Test ID
        : 'ca-app-pub-3940256099942544/1712485313'; // iOS Rewarded Test ID

    dev.log("🎥 AdService: Loading Rewarded Ad ($adUnitId)...");

    void load(bool canRetry) {
      RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            dev.log("🟢 AdService: Rewarded Ad loaded successfully.");
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                dev.log("🔵 AdService: Rewarded Ad dismissed.");
                ad.dispose();
                if (!completer.isCompleted) {
                  completer.complete(true);
                }
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                dev.log("❌ AdService: Rewarded Ad failed to show: $error");
                ad.dispose();
                if (!completer.isCompleted) {
                  completer.complete(false);
                }
              },
            );
            ad.show(
              onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
                dev.log("🎁 AdService: User earned reward: ${reward.amount} ${reward.type}");
              },
            );
          },
          onAdFailedToLoad: (error) {
            dev.log("❌ AdService: Rewarded Ad failed to load: $error");
            if (canRetry) {
              dev.log("🔄 AdService: Retrying Rewarded Ad load once...");
              load(false);
            } else {
              if (!completer.isCompleted) {
                completer.complete(false);
              }
            }
          },
        ),
      );
    }

    load(retryOnFailure);
    return completer.future;
  }

  Future<bool> _showInterstitialAd(bool retryOnFailure) async {
    final completer = Completer<bool>();
    final adUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/1033173712' // Android Interstitial Test ID
        : 'ca-app-pub-3940256099942544/4411468910'; // iOS Interstitial Test ID

    dev.log("🎥 AdService: Loading Interstitial Ad ($adUnitId)...");

    void load(bool canRetry) {
      InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            dev.log("🟢 AdService: Interstitial Ad loaded successfully.");
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                dev.log("🔵 AdService: Interstitial Ad dismissed.");
                ad.dispose();
                if (!completer.isCompleted) {
                  completer.complete(true);
                }
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                dev.log("❌ AdService: Interstitial Ad failed to show: $error");
                ad.dispose();
                if (!completer.isCompleted) {
                  completer.complete(false);
                }
              },
            );
            ad.show();
          },
          onAdFailedToLoad: (error) {
            dev.log("❌ AdService: Interstitial Ad failed to load: $error");
            if (canRetry) {
              dev.log("🔄 AdService: Retrying Interstitial Ad load once...");
              load(false);
            } else {
              if (!completer.isCompleted) {
                completer.complete(false);
              }
            }
          },
        ),
      );
    }

    load(retryOnFailure);
    return completer.future;
  }
}
