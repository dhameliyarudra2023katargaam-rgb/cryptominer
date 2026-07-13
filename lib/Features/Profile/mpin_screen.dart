import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Auth/auth_controller.dart';
import '../../Auth/forgot_password_otp_screen.dart';
import '../../Auth/mpin_controller.dart';
import '../../Service/storage_service.dart';
import '../../Utility/common_color.dart';
import '../../Utility/custom_appbar.dart';
import '../../Utility/font_style.dart';
import '../Home/home_screen.dart';
import '../../Service/Ads/ad_service.dart';

class ProfileMpinController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final RxString currentInput = "".obs;
  final RxString firstPin = "".obs;
  final RxBool isConfirming = false.obs;

  void onKeyPress(String value) {
    if (currentInput.value.length < 4) {
      currentInput.value += value;

      if (currentInput.value.length == 4) {
        // Delay slightly for visual feedback of entering the final digit
        Future.delayed(const Duration(milliseconds: 150), () {
          _handlePinEntered();
        });
      }
    }
  }

  void onBackspacePress() {
    if (currentInput.value.isNotEmpty) {
      currentInput.value = currentInput.value.substring(0, currentInput.value.length - 1);
    }
  }

  void onClearPress() {
    currentInput.value = "";
  }

  void _handlePinEntered() async {
    if (!isConfirming.value) {
      firstPin.value = currentInput.value;
      currentInput.value = "";
      isConfirming.value = true;
    } else {
      if (currentInput.value == firstPin.value) {
        // Pins match, call API
        final success = await _authController.createMpin(currentInput.value);
        if (success) {
          await AdService.instance.showAd(
            adType: 'interstitial',
            retryOnFailure: true,
          );
          Get.offAll(() => const HomeScreenView(initialIndex: 4));
        } else {
          _resetPinFlow();
        }
      } else {
        // Pins do not match
        Get.snackbar(
          "Mismatch",
          "MPINs do not match. Please try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        _resetPinFlow();
      }
    }
  }

  void _resetPinFlow() {
    currentInput.value = "";
    firstPin.value = "";
    isConfirming.value = false;
  }
}

class MpinScreen extends StatelessWidget {
  const MpinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileMpinController controller = Get.put(ProfileMpinController());
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: CommonColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(() => CustomAppBar(
                    title: controller.isConfirming.value ? "Confirm MPIN" : "Create MPIN",
                    fontSize: 24,
                  )),
              const SizedBox(height: 30),

              Icon(
                Icons.lock_outline_rounded,
                color: CommonColor.orange.withValues(alpha: 0.8),
                size: 64,
              ),
              const SizedBox(height: 24),

              Obx(() => Text(
                    controller.isConfirming.value
                        ? "Re-enter your 4-digit MPIN to confirm"
                        : "Enter a 4-digit MPIN to secure your transactions",
                    textAlign: TextAlign.center,
                    style: CommonFontStyles.heading3.copyWith(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  )),
              const SizedBox(height: 40),

              _buildPinDots(controller),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  final MpinController mpinController = Get.put(MpinController());
                  mpinController.emailController.text =
                      SharedPrefHelper.getString("email") ?? "";
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
              const SizedBox(height: 20),

              Obx(() => authController.isLoading.value
                  ? const SizedBox(
                      height: 50,
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
    );
  }

  Widget _buildPinDots(ProfileMpinController controller) {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            bool isFilled = index < controller.currentInput.value.length;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 12),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled ? CommonColor.orange : Colors.transparent,
                border: Border.all(
                  color: isFilled ? CommonColor.orange : Colors.white30,
                  width: 2,
                ),
                boxShadow: isFilled
                    ? [
                        BoxShadow(
                          color: CommonColor.orange.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : [],
              ),
            );
          }),
        ));
  }

  Widget _buildNumericKeypad(ProfileMpinController controller) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton("1", onTap: () => controller.onKeyPress("1")),
            _buildKeypadButton("2", onTap: () => controller.onKeyPress("2")),
            _buildKeypadButton("3", onTap: () => controller.onKeyPress("3")),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton("4", onTap: () => controller.onKeyPress("4")),
            _buildKeypadButton("5", onTap: () => controller.onKeyPress("5")),
            _buildKeypadButton("6", onTap: () => controller.onKeyPress("6")),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton("7", onTap: () => controller.onKeyPress("7")),
            _buildKeypadButton("8", onTap: () => controller.onKeyPress("8")),
            _buildKeypadButton("9", onTap: () => controller.onKeyPress("9")),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton("C", onTap: controller.onClearPress),
            _buildKeypadButton("0", onTap: () => controller.onKeyPress("0")),
            _buildKeypadButton("", icon: Icons.backspace_outlined, onTap: controller.onBackspacePress),
          ],
        ),
      ],
    );
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



