import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'mpin_controller.dart';
import '../Utility/common_color.dart';
import '../Utility/font_style.dart';
import '../Service/storage_service.dart';
import '../Features/Home/home_screen.dart';
import 'forgot_password_otp_screen.dart';

class MpinUnlockScreen extends StatelessWidget {
  const MpinUnlockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MpinController controller = Get.put(MpinController());

    return Scaffold(
      backgroundColor: CommonColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 60.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Icon(
                  Icons.lock_outline_rounded,
                  color: CommonColor.orange.withValues(alpha: 0.8),
                  size: 64,
                ),
                const SizedBox(height: 24),

                // "Unlock using PIN" Label
                Text(
                  "Unlock using PIN",
                  style: CommonFontStyles.heading3.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Enter your 4-digit PIN to secure your session",
                  style: CommonFontStyles.body.copyWith(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),

                // Pin Dots
                _buildPinDots(controller),
                const SizedBox(height: 40),

                // Forgot PIN Button
                TextButton(
                  onPressed: () {
                    controller.emailController.text = SharedPrefHelper.getString("email") ?? "";
                    Get.to(() => const ForgotPasswordOtpScreen());
                  },
                  child: Text(
                    "Forgot PIN?",
                    style: CommonFontStyles.body.copyWith(
                      color: CommonColor.blue,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Keyboard / Loading
                Obx(() => controller.isLoading.value
                    ? const SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: CommonColor.orange,
                          ),
                        ),
                      )
                    : _buildNumericKeypad(controller)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots(MpinController controller) {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            bool isFilled = index < controller.currentInput.value.length;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled ? CommonColor.orange : Colors.transparent,
                border: Border.all(
                  color: isFilled ? CommonColor.orange : Colors.white24,
                  width: 2,
                ),
                boxShadow: isFilled
                    ? [
                        BoxShadow(
                          color: CommonColor.orange.withValues(alpha: 0.3),
                          blurRadius: 6,
                          spreadRadius: 1,
                        )
                      ]
                    : [],
              ),
            );
          }),
        ));
  }

  Widget _buildNumericKeypad(MpinController controller) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton("1", onTap: () => _handleKeyPress(controller, "1")),
            _buildKeypadButton("2", onTap: () => _handleKeyPress(controller, "2")),
            _buildKeypadButton("3", onTap: () => _handleKeyPress(controller, "3")),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton("4", onTap: () => _handleKeyPress(controller, "4")),
            _buildKeypadButton("5", onTap: () => _handleKeyPress(controller, "5")),
            _buildKeypadButton("6", onTap: () => _handleKeyPress(controller, "6")),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton("7", onTap: () => _handleKeyPress(controller, "7")),
            _buildKeypadButton("8", onTap: () => _handleKeyPress(controller, "8")),
            _buildKeypadButton("9", onTap: () => _handleKeyPress(controller, "9")),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 70, height: 70),
            _buildKeypadButton("0", onTap: () => _handleKeyPress(controller, "0")),
            _buildKeypadButton("", icon: Icons.backspace_outlined, onTap: controller.onBackspacePress),
          ],
        ),
      ],
    );
  }

  void _handleKeyPress(MpinController controller, String val) {
    controller.onKeyPress(val, 4, () async {
      bool isSuccess = await controller.loginMpin(controller.currentInput.value);
      controller.currentInput.value = ""; // clear inputs
      if (isSuccess) {
        Get.offAll(() => const HomeScreenView());
      }
    });
  }

  Widget _buildKeypadButton(String label, {VoidCallback? onTap, IconData? icon}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CommonColor.darkGray.withValues(alpha: 0.3),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, color: Colors.white, size: 24)
            : Text(
                label,
                style: CommonFontStyles.heading2.copyWith(fontSize: 22),
              ),
      ),
    );
  }
}
