import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'mpin_controller.dart';
import '../Utility/common_color.dart';
import '../Utility/custom_appbar.dart';
import '../Utility/common_textfield.dart';
import '../Utility/font_style.dart';
import '../Utility/yellow_card.dart';
import 'reset_password_otp_screen.dart';

class ForgotPasswordOtpScreen extends StatelessWidget {
  const ForgotPasswordOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MpinController controller = Get.put(MpinController());

    return Scaffold(
      backgroundColor: CommonColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CustomAppBar(
                title: "Forgot PIN/Password",
                fontSize: 24,
              ),
              const SizedBox(height: 50),

              Icon(
                Icons.mark_email_unread_outlined,
                color: CommonColor.orange.withValues(alpha: 0.8),
                size: 64,
              ),
              const SizedBox(height: 24),

              Text(
                "Enter your registered email address to receive an OTP code to reset your login PIN.",
                textAlign: TextAlign.center,
                style: CommonFontStyles.heading3.copyWith(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 40),

              _buildInputField(
                label: "Email Address",
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                hintText: "example@email.com",
              ),
              const SizedBox(height: 60),

              Obx(() => YellowCard(
                    width: 370,
                    height: 50,
                    borderRadius: 25,
                    onTap: controller.isLoading.value
                        ? null
                        : () async {
                            bool success = await controller.requestForgotPasswordOtp();
                            if (success) {
                              Get.to(() => const ResetPasswordOtpScreen());
                            }
                          },
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Send OTP",
                            style: CommonFontStyles.heading3,
                          ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required String hintText,
  }) {
    return Center(
      child: SizedBox(
        width: 370,
        height: 65,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: 370,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: CommonColor.darkGray,
                  border: Border.all(color: Colors.white10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CommonTextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  hintText: hintText,
                  style: CommonFontStyles.heading3,
                  borderless: true,
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: 2,
              child: Container(
                color: CommonColor.background,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  label,
                  style: CommonFontStyles.body,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
