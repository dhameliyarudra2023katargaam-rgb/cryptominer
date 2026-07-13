import 'package:flutter/material.dart';
import '../../Utility/custom_appbar.dart';
import '../../Service/Ads/banner_ads_service.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_text.dart';
import '../../Utility/black_card.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  // Keeps track of the currently expanded FAQ index (-1 means all closed)
  int _expandedIndex = -1;

  final List<Map<String, String>> _faqs = [
    {
      "question": "What is virtual mining?",
      "answer": "Virtual mining is an in-app simulation that lets you collect virtual rewards. It does not mine real cryptocurrency."
    },
    {
      "question": "Are the rewards real?",
      "answer": "No. All rewards, coins, and mining progress are virtual and intended for entertainment purposes only."
    },
    {
      "question": "How do I start mining?",
      "answer": "Tap the Start Mining button to begin a mining session. Your mining speed depends on your current plan and active boosts."
    },
    {
      "question": "What happens when my mining session ends?",
      "answer": "Once the session ends, simply start a new mining session to continue earning virtual rewards."
    },
    {
      "question": "What is a Speed Boost?",
      "answer": "A Speed Boost increases your estimated in-app mining speed only. It does not provide real cryptocurrency, cash, withdrawals, or investment returns."
    },
    {
      "question": "What are Premium Mining Plans?",
      "answer": "Premium plans offer higher mining speeds, better reward multipliers, premium mining machines, and exclusive daily rewards within the app."
    },
    {
      "question": "Can I withdraw my rewards?",
      "answer": "No. The app does not support cash withdrawals or cryptocurrency withdrawals."
    },
    {
      "question": "How do I claim Daily Rewards?",
      "answer": "Log in every day and tap Claim Daily Rewards to receive virtual coins, mining boosts, and bonus rewards."
    },
    {
      "question": "How does the Invite Friends program work?",
      "answer": "Invite your friends using your referral link. When eligible conditions are met, you can receive bonus virtual rewards and additional mining benefits."
    },
    {
      "question": "I forgot my MPIN. What should I do?",
      "answer": "Use the Forgot MPIN option and verify your identity using your Security Question and Answer to reset your MPIN."
    },
    {
      "question": "Can I change my MPIN?",
      "answer": "Yes. Go to Settings → Change MPIN, verify your current MPIN or Security Question, and set a new MPIN."
    },
    {
      "question": "Is an internet connection required?",
      "answer": "Yes. An internet connection is required for account verification, syncing progress, claiming rewards, and using online features."
    },
    {
      "question": "Can I use the app on multiple devices?",
      "answer": "For account security, your account may be limited to one active device at a time."
    },
    {
      "question": "Why did my mining stop?",
      "answer": "Mining may stop if your session expires, you log out, or there is a network interruption. Simply start a new session."
    },
    {
      "question": "Is this an investment app?",
      "answer": "No. This app is not an investment platform and does not provide financial services, investment advice, or guaranteed returns."
    }
  ];

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
                title: "FAQs",
                fontSize: 24,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  children: List.generate(_faqs.length, (index) {
                    final faq = _faqs[index];
                    final isExpanded = _expandedIndex == index;

                    return GradientBorderContainer(
                      borderRadius: 16,
                      backgroundColor: CommonColor.greyCard,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Accordion Header (Question)
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _expandedIndex = isExpanded ? -1 : index;
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        faq["question"]!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      isExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: Colors.white70,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Accordion Body (Answer)
                            if (isExpanded) ...[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                                child: Text(
                                  faq["answer"]!,
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 12.5,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const AppBanner(),
          ],
        ),
      ),
    );
  }
}
