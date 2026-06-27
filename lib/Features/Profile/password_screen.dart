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
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  final AuthController authController = Get.find<AuthController>();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColor.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40.0,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CustomAppBar(
                        title: "Change Password",
                        titleWidth: 228,
                        titleHeight: 24,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 40),

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
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            final String? email = SharedPrefHelper.getString("email");
                            if (email == null || email.isEmpty) {
                              Get.snackbar(
                                "Error",
                                "Email address not found",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                                colorText: Colors.white,
                              );
                              return;
                            }
                            try {
                              authController.isLoading.value = true;
                              await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
                              await SharedPrefHelper.setBool("pwd_reset_pending", true);
                              CommonDialog.show(
                                title: "Reset Link Sent",
                                message: "Password reset email link sent successfully! Please check your email to reset your password and login again.",
                                isError: false,
                                onClose: () async {
                                  await authController.logout(showSnackbar: false);
                                },
                              );
                            } catch (e) {
                              Get.snackbar(
                                "Error",
                                "Failed to send reset email: $e",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                                colorText: Colors.white,
                              );
                            } finally {
                              authController.isLoading.value = false;
                            }
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: CommonColor.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 180),
                      Obx(() => YellowCard(
                        width: 370,
                        height: 50,
                        borderRadius: 25,
                        onTap: authController.isLoading.value
                            ? null
                            : () {
                                String currentPass = _currentPasswordController.text;
                                String newPass = _newPasswordController.text;
                                String confirmPass = _confirmPasswordController.text;
                                
                                if (currentPass.isEmpty) {
                                  Get.snackbar(
                                    "Error",
                                    "Please enter current password",
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
                                
                                authController.changeUserPassword(
                                  currentPassword: currentPass,
                                  newPassword: newPass,
                                  confirmNewPassword: confirmPass,
                                );
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
                    ],
                  ),
                ),
              ),
            );
          },
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
}