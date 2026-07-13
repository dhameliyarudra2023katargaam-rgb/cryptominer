import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../Utility/common_color.dart';
import '../../Utility/custom_appbar.dart';
import '../../Service/Ads/banner_ads_service.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
    _fetchUrl();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      );
  }

  Future<void> _fetchUrl() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('settings').doc('app_settings').get();
      if (doc.exists && doc.data()!.containsKey('privacy_policy_url')) {
        final fetchedUrl = doc.data()!['privacy_policy_url'];
        if (fetchedUrl != null && fetchedUrl.toString().isNotEmpty) {
          _controller.loadRequest(Uri.parse(fetchedUrl));
        } else {
          setState(() { _isLoading = false; });
        }
      } else {
        setState(() { _isLoading = false; });
      }
    } catch (e) {
      debugPrint('Error fetching Privacy Policy URL: $e');
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColor.background,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              // header space
              // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 4),
              child: CustomAppBar(
                title: "Privacy Policy",
                fontSize: 24,
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
            const AppBanner(),
          ],
        ),
      ),
    );
  }
}
