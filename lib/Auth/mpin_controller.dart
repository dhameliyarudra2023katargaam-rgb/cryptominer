import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Repo/auth_repo.dart';
import '../Service/storage_service.dart';
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
        Get.snackbar(
          "Success",
          responseModel.message ?? "MPIN set successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        return true;
      } else {
        // Fallback to createMpin in case the endpoint routes vary
        AuthModel fallbackModel = await AuthRepo.createMpin(body);
        if (fallbackModel.isSuccess == true) {
          await SharedPrefHelper.setBool("hasMpin", true);
          isSessionUnlocked = true;
          Get.snackbar(
            "Success",
            fallbackModel.message ?? "MPIN set successfully!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.9),
            colorText: Colors.white,
          );
          return true;
        }
        Get.snackbar(
          "Error",
          fallbackModel.message ?? responseModel.message ?? "Failed to set MPIN",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
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
        Get.snackbar(
          "Unlocked",
          responseModel.message ?? "Welcome back!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        await SharedPrefHelper.setBool("hasMpin", true);
        isSessionUnlocked = true;
        return true;
      } else {
        Get.snackbar(
          "Unlock Failed",
          responseModel.message ?? "Invalid MPIN",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      log("Error verifying MPIN: $e");
      Get.snackbar(
        "Error",
        "Something went wrong while unlocking",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Send Forgot Password OTP
  Future<bool> requestForgotPasswordOtp() async {
    final String email = emailController.text.trim();
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar(
        "Invalid Email",
        "Please enter a valid email address",
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
        Get.snackbar(
          "Error",
          responseModel.message ?? "Failed to request OTP",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      log("Error requesting Forgot Password OTP: $e");
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
        Get.snackbar(
          "Error",
          responseModel.message ?? "Failed to reset password",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      log("Error resetting password via OTP: $e");
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
        Get.snackbar(
          "Error",
          responseModel.message ?? "Failed to reset PIN",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      log("Error resetting MPIN directly: $e");
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
}
