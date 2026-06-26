import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Utility/common_color.dart';
import '../Utility/common_text.dart';
import '../Utility/common_textfield.dart';
import '../Utility/custom_appbar.dart';
import '../Utility/blue_card.dart';
import 'auth_controller.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isGoogleUser;
  const ProfileSetupScreen({super.key, required this.isGoogleUser});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final AuthController _controller = Get.find<AuthController>();

  bool _isCheckingUsername = false;
  bool? _isUsernameUnique;
  Timer? _debounceTimer;



  @override
  void initState() {
    super.initState();
    // Add real-time unique username check listener
    _controller.nameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _controller.nameController.removeListener(_onUsernameChanged);
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onUsernameChanged() {
    final String val = _controller.nameController.text.trim();
    _debounceTimer?.cancel();

    if (val.isEmpty) {
      setState(() {
        _isCheckingUsername = false;
        _isUsernameUnique = null;
      });
      return;
    }

    setState(() {
      _isCheckingUsername = true;
      _isUsernameUnique = null;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isCheckingUsername = false;
          _isUsernameUnique = val.length >= 3;
        });
      }
    });
  }

  void _handleCompleteSetup() async {
    final String username = _controller.nameController.text.trim();
    final String dob = _controller.dobController.text.trim();
    final String referral = _controller.referralController.text.trim();

    if (username.isEmpty || username.length < 3) {
      Get.snackbar(
        "Invalid Username",
        "Username must be at least 3 characters long",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    if (dob.isEmpty) {
      Get.snackbar(
        "Required",
        "Please enter your Date of Birth",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    if (widget.isGoogleUser) {
      await _controller.completeGoogleSignup(
        username: username,
        dob: dob,
        referralCode: referral.isNotEmpty ? referral : null,
      );
    } else {
      await _controller.completeEmailSignup(
        username: username,
        dob: dob,
        password: "Pass@123",
        confirmPassword: "Pass@123",
        referralCode: referral.isNotEmpty ? referral : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColor.background,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: "Setup Profile",
              fontSize: 24,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    CommonText.body(
                      "Almost there! Fill in your profile details to complete your account setup.",
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    ),
                    const SizedBox(height: 36),

                    // Email Address (Locked)
                    const CommonText.body(
                      "Email Address (Locked)",
                      style: TextStyle(color: CommonColor.greyColor),
                    ),
                    const SizedBox(height: 8),
                    CommonTextField(
                      controller: _controller.emailController,
                      readOnly: true,
                      suffixIcon: Icon(
                        Icons.lock_outline_rounded,
                        color: Colors.white.withValues(alpha: 0.4),
                        size: 20,
                      ),
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                    const SizedBox(height: 24),

                    // Username Input
                    const CommonText.body(
                      "Username (Unique)",
                      style: TextStyle(color: CommonColor.greyColor),
                    ),
                    const SizedBox(height: 8),
                    CommonTextField(
                      controller: _controller.nameController,
                      hintText: "Enter unique username",
                      suffixIcon: _isCheckingUsername
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: CommonColor.blue,
                                ),
                              ),
                            )
                          : _isUsernameUnique != null
                              ? Icon(
                                  _isUsernameUnique!
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.error_outline_rounded,
                                  color: _isUsernameUnique!
                                      ? CommonColor.green
                                      : CommonColor.red,
                                  size: 20,
                                )
                              : null,
                    ),
                    if (_isUsernameUnique != null) ...[
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          _isUsernameUnique!
                              ? "Username is available!"
                              : "Username is too short or invalid",
                          style: TextStyle(
                            color: _isUsernameUnique!
                                ? CommonColor.green
                                : CommonColor.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Date of Birth Field
                    const CommonText.body(
                      "Date of Birth",
                      style: TextStyle(color: CommonColor.greyColor),
                    ),
                    const SizedBox(height: 8),
                    CommonTextField(
                      controller: _controller.dobController,
                      hintText: "DD/MM/YYYY",
                      readOnly: true,
                      onTap: () => _controller.selectDate(context),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.calendar_today_outlined,
                          color: CommonColor.greyColor,
                          size: 20,
                        ),
                        onPressed: () => _controller.selectDate(context),
                      ),
                    ),
                    const SizedBox(height: 24),


                    // Referral Code (Optional)
                    const CommonText.body(
                      "Referral Code (Optional)",
                      style: TextStyle(color: CommonColor.greyColor),
                    ),
                    const SizedBox(height: 8),
                    CommonTextField(
                      controller: _controller.referralController,
                      hintText: "Enter referral code if any",
                    ),
                    const SizedBox(height: 48),

                    // Complete Setup Button
                    Obx(() {
                      return Center(
                        child: BlueCard(
                          onTap: _controller.isLoading.value ? null : _handleCompleteSetup,
                          child: _controller.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const CommonText.h3(
                                  "Complete Setup",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    }),
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
