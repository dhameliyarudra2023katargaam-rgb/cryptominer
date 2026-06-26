import 'package:flutter/material.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_text.dart';
import '../../Utility/custom_appbar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColor.background,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: "Privacy Policy",
              fontSize: 24,
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: FittedBox(
                  alignment: Alignment.topLeft,
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("1. Introduction"),
                        _buildSectionBody(
                          "Welcome to CryptoMiner. We are committed to protecting your privacy and security. "
                              "This Privacy Policy explains how we collect, use, and safeguard your personal information "
                              "when you use our mobile application.",
                        ),

                        _buildSectionHeader("2. Information We Collect"),
                        _buildSectionBody(
                          "We collect personal information that you provide to us, including your name, email address, "
                              "and security PIN. We also collect device information, IP address, and transaction logs "
                              "related to your mining and withdrawal activities.",
                        ),

                        _buildSectionHeader("3. How We Use Your Information"),
                        _buildSectionBody(
                          "We use your information to operate and maintain your mining session, verify security MPIN, "
                              "process withdrawal transactions, send notifications, and prevent fraudulent activity on "
                              "our platform.",
                        ),

                        _buildSectionHeader("4. Data Security"),
                        _buildSectionBody(
                          "We implement robust administrative, technical, and physical security measures to protect "
                              "your personal information. All communication with our servers is encrypted using Secure "
                              "Sockets Layer (SSL) technology.",
                        ),

                        _buildSectionHeader("5. Your Rights"),
                        _buildSectionBody(
                          "You have the right to access, correct, or delete your personal information. You can manage "
                              "your profile details or request account deletion directly from the Profile screen settings.",
                        ),

                        _buildSectionHeader("6. Changes to this Policy"),
                        _buildSectionBody(
                          "We may update our Privacy Policy from time to time. We will notify you of any changes by "
                              "posting the new policy on this page and updating the effective date.",
                        ),

                        _buildSectionHeader("7. Contact Us"),
                        _buildSectionBody(
                          "If you have any questions or suggestions about our Privacy Policy, do not hesitate to "
                              "contact our support team via the Support section in the app.",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: CommonText.h3(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSectionBody(String text) {
    return CommonText.body(
      text,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade400,
        height: 1.3,
      ),
    );
  }
}