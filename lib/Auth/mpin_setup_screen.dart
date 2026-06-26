import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'mpin_controller.dart';
import '../Utility/common_color.dart';
import '../Utility/custom_appbar.dart';
import '../Utility/font_style.dart';
import '../Features/Home/home_screen.dart';

class MpinSetupScreen extends StatelessWidget {
  const MpinSetupScreen({super.key});

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
              Obx(() => CustomAppBar(
                    title: controller.isConfirming.value ? "Confirm PIN" : "Create PIN",
                    fontSize: 24,
                  )),
              const SizedBox(height: 50),

              Icon(
                Icons.lock_outline_rounded,
                color: CommonColor.orange.withValues(alpha: 0.8),
                size: 64,
              ),
              const SizedBox(height: 24),

              Obx(() => Text(
                    controller.isConfirming.value
                        ? "Re-enter your 4-digit PIN to confirm"
                        : "Enter a 4-digit PIN to secure your account",
                    textAlign: TextAlign.center,
                    style: CommonFontStyles.heading3.copyWith(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  )),
              const SizedBox(height: 40),

              _buildPinDots(controller),
              const SizedBox(height: 60),

              Obx(() => controller.isLoading.value
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

  Widget _buildPinDots(MpinController controller) {
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
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton("4", onTap: () => _handleKeyPress(controller, "4")),
            _buildKeypadButton("5", onTap: () => _handleKeyPress(controller, "5")),
            _buildKeypadButton("6", onTap: () => _handleKeyPress(controller, "6")),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton("7", onTap: () => _handleKeyPress(controller, "7")),
            _buildKeypadButton("8", onTap: () => _handleKeyPress(controller, "8")),
            _buildKeypadButton("9", onTap: () => _handleKeyPress(controller, "9")),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton("C", onTap: controller.onClearPress),
            _buildKeypadButton("0", onTap: () => _handleKeyPress(controller, "0")),
            _buildKeypadButton("", icon: Icons.backspace_outlined, onTap: controller.onBackspacePress),
          ],
        ),
      ],
    );
  }

  void _handleKeyPress(MpinController controller, String val) {
    controller.onKeyPress(val, 4, () async {
      if (!controller.isConfirming.value) {
        controller.firstPin.value = controller.currentInput.value;
        controller.currentInput.value = "";
        controller.isConfirming.value = true;
      } else {
        if (controller.currentInput.value == controller.firstPin.value) {
          bool isSuccess = await controller.setMpin(controller.currentInput.value);
          if (isSuccess) {
            Get.offAll(() => const HomeScreenView(initialIndex: 4));
          } else {
            _resetPinFlow(controller);
          }
        } else {
          Get.snackbar(
            "Mismatch",
            "PINs do not match. Please try again.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
            colorText: Colors.white,
          );
          _resetPinFlow(controller);
        }
      }
    });
  }

  void _resetPinFlow(MpinController controller) {
    controller.currentInput.value = "";
    controller.firstPin.value = "";
    controller.isConfirming.value = false;
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
