import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../Utility/common_color.dart';
import '../../Utility/image_const.dart';
import '../../Utility/common_text.dart';
import '../../Auth/login_screen.dart';
import '../../Service/storage_service.dart';
import '../../Service/Ads/native_ads_service.dart';
class OnboardingScreenView extends StatefulWidget {
  const OnboardingScreenView({super.key});

  @override
  State<OnboardingScreenView> createState() => _OnboardingScreenViewState();
}

class _OnboardingScreenViewState extends State<OnboardingScreenView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "welcome": "WELCOME TO",
      "title": "VIRTUAL MINING",
      "subtitle": "Start your mining journey and earn exciting virtual rewards every day.",
      "titleColor": CommonColor.blue,
      "image": ImageConst.onboardingScreen1,
    },
    {
      "welcome": "BOOST YOUR",
      "title": "MINING SPEED",
      "subtitle": "Upgrade machines, activate boosts and increase your estimated mining speed.",
      "titleColor": CommonColor.blue,
      "image": ImageConst.onboardingScreen2,
    },
    {
      "welcome": "EARN MORE",
      "title": "REWARDS",
      "subtitle": "Complete daily tasks, claim bonuses and unlock amazing rewards.",
      "titleColor": CommonColor.orange,
      "image": ImageConst.onboardingScreen3,
    }
  ];

  void _onNextPressed() async {
    if (_currentPage == _onboardingData.length - 1) {
      await SharedPrefHelper.setBool("hasSeenOnboarding", true);
      Get.offAll(() => const LoginScreenView());
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: CommonColor.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F0223), // Dark purple/indigo glow at the top
              Color(0xFF010101), // Fades to solid black
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // 1. Top Illustration Area (with beautiful cross-fade between slides)
            Expanded(
              flex: 12,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Image.asset(
                  _onboardingData[_currentPage]["image"]!,
                  key: ValueKey<int>(_currentPage),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),

            // 2. Native Ad Card and Bottom Controls
            Expanded(
              flex: 16,
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Center(child: AppNativeAd()),
                  ),

                  const SizedBox(height: 4),

                  // 3. PageView Text Slides Area
                  SizedBox(
                    height: 150,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: _onboardingData.length,
                      itemBuilder: (context, index) {
                        final slide = _onboardingData[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CommonText(
                                slide["welcome"]!,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal, // SemiBold
                                  color: Colors.white,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              CommonText.h1(
                                slide["title"]!,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 36,
                                  fontWeight: FontWeight.normal, // Bold (700)
                                  color: slide["titleColor"] as Color,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              CommonText.body(
                                slide["subtitle"]!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal, // Regular
                                  color: Colors.white.withValues(alpha: 0.65),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. Dot Indicators (Cumulative progress styling matching mockups)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index <= _currentPage
                              ? CommonColor.blue
                              : Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 5. Next/Start Min Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _onNextPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CommonColor.blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: CommonText.body(
                          _currentPage == _onboardingData.length - 1 ? "Start Min" : "Next",
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
      ),
    );
  }
}
