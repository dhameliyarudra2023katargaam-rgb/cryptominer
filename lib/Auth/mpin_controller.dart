import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Repo/auth_repo.dart';
import '../Service/storage_service.dart';
import '../Utility/app_snackbar.dart';
import '../Utility/common_dialog.dart';
import 'auth_model.dart';
import 'login_screen.dart';

class MpinController extends GetxController {
  static bool isSessionUnlocked = false;
  final RxBool isLoading = false.obs;
  final RxString currentInput = "".obs;
  final RxString firstPin = "".obs;
  final RxBool isConfirming = false.obs;

  // Forgot/Reset password OTP inputs
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void onKeyPress(String value, int maxLength, VoidCallback onComplete) {
    if (currentInput.value.length < maxLength) {
      currentInput.value += value;
      if (currentInput.value.length == maxLength) {
        Future.delayed(const Duration(milliseconds: 150), () {
          onComplete();
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

  // Set/Create MPIN
  Future<bool> setMpin(String mpin) async {
    try {
      isLoading.value = true;
      final Map<String, dynamic> body = {
        "mpin": mpin,
      };
      
      AuthModel responseModel = await AuthRepo.setMpin(body);
      if (responseModel.isSuccess == true) {
        await SharedPrefHelper.setBool("hasMpin", true);
        isSessionUnlocked = true;
        
        // Sync MPIN to Firestore
        final String? email = SharedPrefHelper.getString("email");
        if (email != null && email.isNotEmpty) {
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(email.trim().toLowerCase())
                .set({"mpin": mpin}, SetOptions(merge: true));
          } catch (e) {
            log("Firestore mpin update failed: $e");
          }
        }

        AppSnackbar.success(responseModel.message ?? "MPIN set successfully!");
        return true;
      } else {
        // Fallback to createMpin in case the endpoint routes vary
        AuthModel fallbackModel = await AuthRepo.createMpin(body);
        if (fallbackModel.isSuccess == true) {
          await SharedPrefHelper.setBool("hasMpin", true);
          isSessionUnlocked = true;
          
          // Sync MPIN to Firestore
          final String? email = SharedPrefHelper.getString("email");
          if (email != null && email.isNotEmpty) {
            try {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(email.trim().toLowerCase())
                  .set({"mpin": mpin}, SetOptions(merge: true));
            } catch (e) {
              log("Firestore mpin update failed: $e");
            }
          }

          AppSnackbar.success(fallbackModel.message ?? "MPIN set successfully!");
          return true;
        }
        AppSnackbar.error(fallbackModel.message ?? responseModel.message ?? "Failed to set MPIN");
        return false;
      }
    } catch (e) {
      log("Error setting MPIN: $e");
      Get.snackbar(
        "Error",
        "Something went wrong",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Verify/Login using MPIN
  Future<bool> loginMpin(String mpin) async {
    try {
      isLoading.value = true;
      final String email = SharedPrefHelper.getString("email") ?? "";
      final Map<String, dynamic> body = {
        "email": email,
        "mpin": mpin,
      };
      AuthModel responseModel = await AuthRepo.loginMpin(body);
      if (responseModel.isSuccess == true) {
        if (responseModel.data?.token != null) {
          await SharedPrefHelper.setString("token", responseModel.data!.token!);
        }
        AppSnackbar.success(responseModel.message ?? "Welcome back!", title: "Unlocked");
        await SharedPrefHelper.setBool("hasMpin", true);
        isSessionUnlocked = true;
        return true;
      } else {
        AppSnackbar.error(responseModel.message ?? "Invalid MPIN", title: "Unlock Failed");
        return false;
      }
    } catch (e) {
      log("Error verifying MPIN: $e");
      AppSnackbar.error("Something went wrong while unlocking");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Send Forgot Password OTP
  Future<bool> requestForgotPasswordOtp() async {
    final String email = emailController.text.trim();
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      AppSnackbar.error("Please enter a valid email address", title: "Invalid Email");
      return false;
    }

    try {
      isLoading.value = true;
      final Map<String, dynamic> body = {
        "email": email,
      };
      AuthModel responseModel = await AuthRepo.forgotMpinOtp(body);
      if (responseModel.isSuccess == true) {
        CommonDialog.show(
          title: "OTP Sent",
          message: responseModel.message ?? "Verification code sent to your email",
          isError: false,
        );
        return true;
      } else {
        AppSnackbar.error(responseModel.message ?? "Failed to request OTP");
        return false;
      }
    } catch (e) {
      log("Error requesting Forgot Password OTP: $e");
      AppSnackbar.error("Something went wrong");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Reset Password OTP
  Future<bool> submitResetPasswordOtp() async {
    final String email = emailController.text.trim();
    final String otp = otpController.text.trim();
    final String password = newPasswordController.text.trim();
    final String confirmPassword = confirmPasswordController.text.trim();

    if (password.isEmpty || password.length < 4) {
      Get.snackbar(
        "Invalid PIN",
        "PIN must be at least 4 digits",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return false;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        "Mismatch",
        "PINs do not match",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return false;
    }

    try {
      isLoading.value = true;
      final Map<String, dynamic> body = {
        "email": email,
        "otp": otp,
        "mpin": password,
      };
      AuthModel responseModel = await AuthRepo.resetMpinOtp(body);
      if (responseModel.isSuccess == true) {
        emailController.clear();
        otpController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
        CommonDialog.show(
          title: "PIN Changed",
          message: responseModel.message ?? "PIN reset successfully! Please login with your new PIN.",
          isError: false,
          onClose: () {
            Get.offAll(() => const LoginScreenView());
          },
        );
        return true;
      } else {
        AppSnackbar.error(responseModel.message ?? "Failed to reset password");
        return false;
      }
    } catch (e) {
      log("Error resetting password via OTP: $e");
      AppSnackbar.error("Something went wrong");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Reset MPIN directly (after Firebase link verification, no OTP needed)
  Future<bool> resetMpinDirect() async {
    final String newPin = newPasswordController.text.trim();
    final String confirmPin = confirmPasswordController.text.trim();

    if (newPin.isEmpty || newPin.length < 4) {
      Get.snackbar(
        "Invalid PIN",
        "PIN must be at least 4 digits",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return false;
    }

    if (newPin != confirmPin) {
      Get.snackbar(
        "Mismatch",
        "PINs do not match",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return false;
    }

    try {
      isLoading.value = true;
      final Map<String, dynamic> body = {
        "mpin": newPin,
      };

      AuthModel responseModel = await AuthRepo.setMpin(body);
      if (responseModel.isSuccess == true) {
        await SharedPrefHelper.setBool("hasMpin", true);
        newPasswordController.clear();
        confirmPasswordController.clear();
        CommonDialog.show(
          title: "PIN Changed",
          message: responseModel.message ?? "PIN reset successfully! Please login with your new PIN.",
          isError: false,
          onClose: () {
            Get.offAll(() => const LoginScreenView());
          },
        );
        return true;
      } else {
        AppSnackbar.error(responseModel.message ?? "Failed to reset PIN");
        return false;
      }
    } catch (e) {
      log("Error resetting MPIN directly: $e");
      AppSnackbar.error("Something went wrong");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
