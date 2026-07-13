import 'package:flutter/material.dart';

import '../../Utility/black_card.dart';
import '../../Utility/common_textfield.dart';
import '../../Utility/common_color.dart';
import '../../Utility/custom_appbar.dart';
import '../../Utility/font_style.dart';
import '../../Utility/yellow_card.dart';
import '../../Utility/common_dialog.dart';
import 'package:get/get.dart';
import '../../Auth/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Service/storage_service.dart';
import '../../Utility/app_snackbar.dart';
import '../../Utility/image_const.dart';
import '../../Service/Ads/ad_service.dart';

class PasswordMpnScreen extends StatefulWidget {
  const PasswordMpnScreen({super.key});

  @override
  State<PasswordMpnScreen> createState() => _PasswordMpnScreenState();
}

class _PasswordMpnScreenState extends State<PasswordMpnScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String? _selectedQuestion;
  final List<String> _securityQuestions = [
    "What is your favorite hash rate?",
  ];

  final AuthController authController = Get.find<AuthController>();

  bool get _hasPassword {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    return user.providerData.any((info) => info.providerId == 'password');
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColor.background,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 0, left: 20, right: 20),
              child: CustomAppBar(
                title: "Change Password",
                titleWidth: 228,
                titleHeight: 24,
                fontSize: 24,
                // fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                      // Security Questions Dropdown
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Security Questions",
                          style: CommonFontStyles.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          width: 370,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: CommonColor.darkGray,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedQuestion,
                              hint: const Text(
                                "Select a security question",
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              isExpanded: true,
                              dropdownColor: CommonColor.darkGray,
                              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                              style: CommonFontStyles.body.copyWith(color: Colors.white),
                              items: _securityQuestions.map((q) {
                                return DropdownMenuItem<String>(
                                  value: q,
                                  child: Text(q, style: const TextStyle(fontSize: 13)),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedQuestion = val),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Answer Field
                      _buildAnswerField(),
                      const SizedBox(height: 24),

                      if (_hasPassword) ...[
                        _buildPasswordField(
                          label: "Current Password",
                          controller: _currentPasswordController,
                          obscureText: _obscureCurrentPassword,
                          onToggleVisibility: () {
                            setState(() {
                              _obscureCurrentPassword = !_obscureCurrentPassword;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                      ],

                      _buildPasswordField(
                        label: "New Password",
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      _buildPasswordField(
                        label: "Confirm Password",
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      // const SizedBox(height: 10),
                      // Align(
                      //   alignment: Alignment.centerRight,
                      //   child: TextButton(
                      //     onPressed: () async {
                      //       final String? email = SharedPrefHelper.getString("email");
                      //       if (email == null || email.isEmpty) {
                      //         Get.snackbar(
                      //           "Error",
                      //           "Email address not found",
                      //           snackPosition: SnackPosition.BOTTOM,
                      //           backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                      //           colorText: Colors.white,
                      //         );
                      //         return;
                      //       }
                      //       try {
                      //         authController.isLoading.value = true;
                      //         await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
                      //         await SharedPrefHelper.setBool("pwd_reset_pending", true);
                      //         CommonDialog.show(
                      //           title: "Reset Link Sent",
                      //           message: "Password reset email link sent successfully! Please check your email to reset your password and login again.",
                      //           isError: false,
                      //           onClose: () async {
                      //             await authController.logout(showSnackbar: false);
                      //           },
                      //         );
                      //       } catch (e) {
                      //         Get.snackbar(
                      //           "Error",
                      //           "Failed to send reset email: $e",
                      //           snackPosition: SnackPosition.BOTTOM,
                      //           backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                      //           colorText: Colors.white,
                      //         );
                      //       } finally {
                      //         authController.isLoading.value = false;
                      //       }
                      //     },
                      //     child: const Text(
                      //       "Forgot Password?",
                      //       style: TextStyle(
                      //         color: CommonColor.blue,
                      //         fontSize: 14,
                      //         fontWeight: FontWeight.normal,
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      const SizedBox(height: 32),
                      Obx(() => YellowCard(
                        width: 370,
                        height: 50,
                        borderRadius: 25,
                        onTap: authController.isLoading.value
                            ? null
                            : () async {
                                String answer = _answerController.text.trim();
                                String currentPass = _hasPassword ? _currentPasswordController.text : "";
                                String newPass = _newPasswordController.text;
                                String confirmPass = _confirmPasswordController.text;
                                
                                if (_hasPassword && currentPass.isEmpty) {
                                  Get.snackbar(
                                    "Error",
                                    "Please enter current password",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                                if (answer.isEmpty) {
                                  Get.snackbar(
                                    "Error",
                                    "Please enter answer",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                                if (newPass.isEmpty) {
                                  Get.snackbar(
                                    "Error",
                                    "Please enter new password",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                                if (newPass.length < 8) {
                                  Get.snackbar(
                                    "Error",
                                    "Password must be at least 8 characters long",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                                if (newPass != confirmPass) {
                                  Get.snackbar(
                                    "Error",
                                    "New passwords do not match",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                                
                                bool success = await authController.changeUserPassword(
                                  currentPassword: currentPass,
                                  answer: answer,
                                  newPassword: newPass,
                                  confirmNewPassword: confirmPass,
                                );

                                if (success) {
                                  await AdService.instance.showAd(
                                    adType: 'interstitial',
                                    retryOnFailure: true,
                                  );
                                  Get.back();
                                }
                              },
                        child: authController.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Save",
                                style: CommonFontStyles.heading3,
                              ),
                      )),
                      const SizedBox(height: 24),
                      const _PasswordAdBanner(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
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
              child: GradientBorderContainer(
                width: 370,
                height: 55,
                borderRadius: 16,
                backgroundColor: CommonColor.darkGray,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: CommonTextField(
                        controller: controller,
                        obscureText: obscureText,
                        style: CommonFontStyles.heading3,
                        borderless: true,
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

  Widget _buildAnswerField() {
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
              child: GradientBorderContainer(
                width: 370,
                height: 55,
                borderRadius: 16,
                backgroundColor: CommonColor.darkGray,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CommonTextField(
                  controller: _answerController,
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
                  "Answer",
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


class _PasswordAdBanner extends StatelessWidget {
  const _PasswordAdBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 371,
      height: 258,
      decoration: BoxDecoration(
        color: CommonColor.greyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top half: Big image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: SizedBox(
              width: double.infinity,
              height: 135,
              child: Image.asset(
                ImageConst.halfBitcoinImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Bottom half: Details & Install button
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: Image.asset(
                            ImageConst.bitcoinImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "BTC Mining Cloud Bitcoin Miner",
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    "AD",
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontSize: 7,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Row(
                                  children: List.generate(5, (index) => const Icon(
                                    Icons.star,
                                    color: Color(0xFFF49518),
                                    size: 10,
                                  )),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Now you can! Dive into the world of cryptocurrency with our easy-to-use BTC cloud mining platform.",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 9,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      AppSnackbar.success("Installation started!");
                    },
                    child: Container(
                      width: double.infinity,
                      height: 32,
                      decoration: BoxDecoration(
                        color: CommonColor.blue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Install",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
