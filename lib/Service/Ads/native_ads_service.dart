import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppNativeAd extends StatefulWidget {
  final VoidCallback? onInstallTap;
  final String factoryId;

  const AppNativeAd({
    super.key,
    this.onInstallTap,
    this.factoryId = 'customNativeAd',
  });

  @override
  State<AppNativeAd> createState() => _AppNativeAdState();
}

class _AppNativeAdState extends State<AppNativeAd> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd(); 
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: 'ca-app-pub-3940256099942544/2247696110', // Test Native ID
      factoryId: widget.factoryId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('AppNativeAd failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _nativeAd != null) {
      return SizedBox(
        height: 65,
        width: double.infinity,
        child: AdWidget(ad: _nativeAd!),
      );
    }

    // Return empty space if ad is not loaded
    return const SizedBox.shrink();
  }
}
//42407561167
//SBIN0016040
