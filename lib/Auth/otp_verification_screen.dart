import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Utility/common_color.dart';
import '../Utility/common_text.dart';
import '../Utility/custom_appbar.dart';
import '../Utility/blue_card.dart';
import 'auth_controller.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: CommonColor.background,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: "Verify Email",
              fontSize: 24,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Icon(
                      Icons.mark_email_read_outlined,
                      color: CommonColor.blue.withValues(alpha: 0.8),
                      size: 80,
                    ),
                    const SizedBox(height: 40),

                    CommonText.h2(
                      "Check your email",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Obx(() {
                      return RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 16,
                            height: 1.5,
                            fontFamily: 'Gayathri',
                          ),
                          children: [
                            const TextSpan(text: "We have sent a confirmation email to\n"),
                            TextSpan(
                              text: controller.signupEmail.value,
                              style: const TextStyle(
                                color: CommonColor.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text: ".\n\nPlease check your inbox and click the verification link to verify your account.",
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 60),

                    // Continue Button (After verification)
                    BlueCard(
                      onTap: () {
                        controller.startVerificationListener(controller.signupEmail.value);
                        Get.snackbar(
                          "Checking Status",
                          "Checking verification status. Once the link is verified, your account will open automatically.",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.blue.withValues(alpha: 0.9),
                          colorText: Colors.white,
                        );
                      },
                      child: const CommonText.h3(
                        "Continue",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Resend link
                    GestureDetector(
                      onTap: () {
                        controller.resendVerificationEmail();
                      },
                      child: const CommonText.body(
                        "Resend Confirmation Email",
                        style: TextStyle(
                          color: CommonColor.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
