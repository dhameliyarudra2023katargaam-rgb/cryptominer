import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../Utility/common_color.dart';

class AppBanner extends StatefulWidget {
  const AppBanner({super.key});

  @override
  State<AppBanner> createState() => _AppBannerState();
}

class _AppBannerState extends State<AppBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  AdSize? _adSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null) {
      _loadAd();
    }
  }

  void _loadAd() async {
    final double width = MediaQuery.of(context).size.width;
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getAnchoredAdaptiveBannerAdSize(
            Orientation.portrait, width.truncate());

    if (size == null) return;

    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test Banner ID
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _adSize = size;
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('AppBanner failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null && _adSize != null) {
      return SizedBox(
        width: double.infinity,
        height: _adSize!.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Fallback banner design
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: CommonColor.greyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.0,
        ),
      ),
      child: const Center(
        child: Text(
          "SPONSOR AD",
          style: TextStyle(
            color: Colors.white60,
            fontWeight: FontWeight.normal,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
