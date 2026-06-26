import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Utility/common_color.dart';
import '../Utility/common_text.dart';
import '../Utility/common_textfield.dart';
import '../Utility/custom_appbar.dart';
import '../Utility/blue_card.dart';
import 'auth_controller.dart';
import 'otp_verification_screen.dart';

class EmailSignUpScreen extends GetView<AuthController> {
  const EmailSignUpScreen({super.key});

  void _handleSubmit(BuildContext context) async {
    final String email = controller.emailController.text.trim().toLowerCase();

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

    if (controller.isSignUpMode.value) {
      final String username = controller.nameController.text.trim();
      final String dob = controller.dobController.text.trim();
      final String password = controller.passwordController.text.trim();

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

      if (password.isEmpty || password.length < 6) {
        Get.snackbar(
          "Invalid Password",
          "Password must be at least 6 characters long",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        return;
      }

      // Save email locally in AuthController for OTP verification link matching
      controller.emailController.text = email;

      // Tapping Sign Up sends verification link and navigates to pending screen
      final String referralCode = controller.referralController.text.trim();
      bool success = await controller.initiateEmailSignUp(
        email: email,
        username: username,
        dob: dob,
        password: password,
        referralCode: referralCode.isNotEmpty ? referralCode : null,
      );
      if (success) {
        controller.startVerificationListener(email);
        Get.to(() => const OtpVerificationScreen());
      }
    } else {
      // Sign In mode requires Password
      final String password = controller.passwordController.text.trim();
      if (password.isEmpty || password.length < 6) {
        Get.snackbar(
          "Invalid Password",
          "Password must be at least 6 characters long",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        return;
      }
      await controller.loginWithEmailPassword(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColor.background,
      body: SafeArea(
        child: Column(
          children: [
            Obx(() => CustomAppBar(
                  title: controller.isSignUpMode.value ? "Sign Up" : "Sign In",
                  fontSize: 24,
                )),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Toggle Tabs (Sign Up vs Sign In)
                    Obx(() => Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  controller.isSignUpMode.value = true;
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: controller.isSignUpMode.value
                                            ? CommonColor.blue
                                            : Colors.white.withValues(alpha: 0.1),
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                  child: CommonText.h3(
                                    "Sign Up",
                                    style: TextStyle(
                                      color: controller.isSignUpMode.value
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.4),
                                      fontWeight: controller.isSignUpMode.value
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  controller.isSignUpMode.value = false;
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: !controller.isSignUpMode.value
                                            ? CommonColor.blue
                                            : Colors.white.withValues(alpha: 0.1),
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                  child: CommonText.h3(
                                    "Sign In",
                                    style: TextStyle(
                                      color: !controller.isSignUpMode.value
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.4),
                                      fontWeight: !controller.isSignUpMode.value
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                    const SizedBox(height: 40),

                    // Email Field
                    const CommonText.body(
                      "Email Address",
                      style: TextStyle(color: CommonColor.greyColor),
                    ),
                    const SizedBox(height: 8),
                    CommonTextField(
                      controller: controller.emailController,
                      hintText: "example@email.com",
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),

                    // Fields only for Sign Up Mode
                    Obx(() {
                      if (!controller.isSignUpMode.value) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Username (Unique)
                          const CommonText.body(
                            "Username (Unique)",
                            style: TextStyle(color: CommonColor.greyColor),
                          ),
                          const SizedBox(height: 8),
                          CommonTextField(
                            controller: controller.nameController,
                            hintText: "Enter unique username",
                            onChanged: (val) => controller.onUsernameChanged(val),
                            suffixIcon: controller.isCheckingUsername.value
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
                                : controller.isUsernameUnique.value != null
                                    ? Icon(
                                        controller.isUsernameUnique.value!
                                            ? Icons.check_circle_outline_rounded
                                            : Icons.error_outline_rounded,
                                        color: controller.isUsernameUnique.value!
                                            ? CommonColor.green
                                            : CommonColor.red,
                                        size: 20,
                                      )
                                    : null,
                          ),
                          if (controller.isUsernameUnique.value != null) ...[
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Text(
                                controller.isUsernameUnique.value!
                                    ? "Username is available!"
                                    : "Username is too short or invalid",
                                style: TextStyle(
                                  color: controller.isUsernameUnique.value!
                                      ? CommonColor.green
                                      : CommonColor.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),

                          // Date of Birth
                          const CommonText.body(
                            "Date of Birth",
                            style: TextStyle(color: CommonColor.greyColor),
                          ),
                          const SizedBox(height: 8),
                          CommonTextField(
                            controller: controller.dobController,
                            hintText: "DD/MM/YYYY",
                            readOnly: true,
                            onTap: () => controller.selectDate(context),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.calendar_today_outlined,
                                color: CommonColor.greyColor,
                                size: 20,
                              ),
                              onPressed: () => controller.selectDate(context),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Password
                          const CommonText.body(
                            "Password",
                            style: TextStyle(color: CommonColor.greyColor),
                          ),
                          const SizedBox(height: 8),
                          CommonTextField(
                            controller: controller.passwordController,
                            hintText: "Enter password",
                            obscureText: controller.obscurePassword.value,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.obscurePassword.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: CommonColor.greyColor,
                                size: 20,
                              ),
                              onPressed: () {
                                controller.obscurePassword.value = !controller.obscurePassword.value;
                              },
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
                            controller: controller.referralController,
                            hintText: "Enter referral code if any",
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }),

                    // Password Field (Only for Sign In Mode)
                    Obx(() {
                      if (controller.isSignUpMode.value) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CommonText.body(
                            "Password",
                            style: TextStyle(color: CommonColor.greyColor),
                          ),
                          const SizedBox(height: 8),
                          CommonTextField(
                            controller: controller.passwordController,
                            hintText: "Enter password",
                            obscureText: controller.obscurePassword.value,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.obscurePassword.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: CommonColor.greyColor,
                                size: 20,
                              ),
                              onPressed: () {
                                controller.obscurePassword.value = !controller.obscurePassword.value;
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }),

                    const SizedBox(height: 24),

                    // Action Button (Send OTP / Sign In)
                    Obx(() {
                      return Center(
                        child: BlueCard(
                          onTap: controller.isLoading.value ? null : () => _handleSubmit(context),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : CommonText.h3(
                                  controller.isSignUpMode.value ? "Verify Email" : "Sign In",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    }),
                    const SizedBox(height: 30),

                    // Bottom helper link to toggle mode
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          controller.isSignUpMode.value = !controller.isSignUpMode.value;
                        },
                        child: Obx(() => CommonText.body(
                              controller.isSignUpMode.value
                                  ? "Already have an account? Sign In"
                                  : "Don't have an account? Sign Up",
                              style: const TextStyle(
                                color: CommonColor.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
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
