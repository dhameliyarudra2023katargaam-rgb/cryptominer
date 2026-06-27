import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Utility/common_textfield.dart';
import 'mpin_controller.dart';
import '../Utility/common_color.dart';
import '../Utility/custom_appbar.dart';
import '../Utility/font_style.dart';
import '../Utility/yellow_card.dart';

class ResetPasswordOtpScreen extends StatefulWidget {
  const ResetPasswordOtpScreen({super.key});

  @override
  State<ResetPasswordOtpScreen> createState() => _ResetPasswordOtpScreenState();
}

class _ResetPasswordOtpScreenState extends State<ResetPasswordOtpScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
                title: "Reset PIN",
                fontSize: 24,
              ),
              const SizedBox(height: 40),

              Icon(
                Icons.lock_reset_outlined,
                color: CommonColor.orange.withValues(alpha: 0.8),
                size: 64,
              ),
              const SizedBox(height: 24),

              Text(
                "Set and confirm your new 4-digit PIN.",
                textAlign: TextAlign.center,
                style: CommonFontStyles.heading3.copyWith(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 30),

              // New MPIN
              _buildPasswordField(
                label: "New MPIN",
                controller: controller.newPasswordController,
                obscureText: _obscurePassword,
                keyboardType: TextInputType.number,
                maxLength: 4,
                onToggleVisibility: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Confirm MPIN
              _buildPasswordField(
                label: "Confirm MPIN",
                controller: controller.confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                keyboardType: TextInputType.number,
                maxLength: 4,
                onToggleVisibility: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              const SizedBox(height: 40),

              Obx(() => YellowCard(
                    width: 370,
                    height: 50,
                    borderRadius: 25,
                    onTap: controller.isLoading.value
                        ? null
                        : () async {
                            await controller.resetMpinDirect();
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
                            "Reset PIN",
                            style: CommonFontStyles.heading3,
                          ),
                  )),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    TextInputType? keyboardType,
    int? maxLength,
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
                child: Row(
                  children: [
                    Expanded(
                      child: CommonTextField(
                        controller: controller,
                        obscureText: obscureText,
                        hintText: "••••",
                        style: CommonFontStyles.heading3,
                        borderless: true,
                        keyboardType: keyboardType,
                        maxLength: maxLength,
                      ),
                    ),
                    GestureDetector(
                      onTap: onToggleVisibility,
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: Icon(
                          obscureText
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
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
