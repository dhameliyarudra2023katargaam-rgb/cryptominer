import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'mpin_controller.dart';
import '../Utility/common_color.dart';
import '../Utility/custom_appbar.dart';
import '../Utility/common_textfield.dart';
import '../Utility/font_style.dart';
import '../Utility/yellow_card.dart';
import '../Utility/common_dialog.dart';
import '../Service/storage_service.dart';
import 'reset_password_otp_screen.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  const ForgotPasswordOtpScreen({super.key});

  @override
  State<ForgotPasswordOtpScreen> createState() => _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen>
    with WidgetsBindingObserver {
  bool _linkSent = false;
  final MpinController controller = Get.put(MpinController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Pre-fill email from saved data
    controller.emailController.text = SharedPrefHelper.getString("email") ?? "";
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _linkSent) {
      _linkSent = false;
      Future.delayed(const Duration(milliseconds: 500), () {
        CommonDialog.show(
          title: "Verified Successfully",
          message: "Your identity has been verified. You can now set a new PIN.",
          isError: false,
          onClose: () {
            Get.off(() => const ResetPasswordOtpScreen());
          },
        );
      });
    }
  }

  Future<void> _sendVerificationLink() async {
    final String email = controller.emailController.text.trim();
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar(
        "Invalid Email",
        "Please enter a valid email address",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    try {
      controller.isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        setState(() {
          _linkSent = true;
        });
        CommonDialog.show(
          title: "Verification Link Sent",
          message:
              "A verification link has been sent to your email. Please check your email and click the link to verify your identity.",
          isError: false,
        );
      } else {
        Get.snackbar(
          "Error",
          "No active user session found. Please login again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to send verification link: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      controller.isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                title: "Forgot PIN",
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
                "Enter your registered email address. We'll send a verification link to confirm your identity.",
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
                            await _sendVerificationLink();
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
                            "Continue",
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
