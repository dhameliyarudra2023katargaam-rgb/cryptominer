import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Utility/common_text.dart';
import '../Api/api_response.dart';
import '../Repo/auth_repo.dart';
import '../Service/storage_service.dart';
import '../Service/socket_service.dart';
import 'auth_model.dart';
import 'login_screen.dart';
import 'profile_setup_screen.dart';
import '../Features/Home/home_screen.dart';
import 'mpin_unlock_screen.dart';
import 'mpin_controller.dart';
import 'otp_verification_screen.dart';
import 'email_signup_screen.dart';
import '../Service/notification_service.dart';

class AuthController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();
  final referralController = TextEditingController();
  final pinController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  
  // Reactive view states
  final RxBool isSignUpMode = true.obs;
  final RxBool obscurePin = true.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool isCheckingUsername = false.obs;
  final Rxn<bool> isUsernameUnique = Rxn<bool>();
  
  Timer? _usernameDebounceTimer;
  StreamSubscription<DocumentSnapshot>? _verificationSubscription;
  Timer? _verificationTimer;

  void onUsernameChanged(String val) {
    _usernameDebounceTimer?.cancel();
    final cleanVal = val.trim();

    if (cleanVal.isEmpty) {
      isCheckingUsername.value = false;
      isUsernameUnique.value = null;
      return;
    }

    isCheckingUsername.value = true;
    isUsernameUnique.value = null;

    _usernameDebounceTimer = Timer(const Duration(milliseconds: 600), () {
      isCheckingUsername.value = false;
      isUsernameUnique.value = cleanVal.length >= 3;
    });
  }

  ApiResponse<AuthModel> apiResponse = ApiResponse.initial(
    message: 'Initialization',
  );
  //
  // @override
  // void onClose() {
  //   nameController.dispose();
  //   emailController.dispose();
  //   dobController.dispose();
  //   referralController.dispose();
  //   pinController.dispose();
  //   passwordController.dispose();
  //   _usernameDebounceTimer?.cancel();
  //   _verificationSubscription?.cancel();
  //   super.onClose();
  // }



  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    dobController.dispose();
    referralController.dispose();
    pinController.dispose();
    passwordController.dispose();

    _usernameDebounceTimer?.cancel();
    _verificationTimer?.cancel();

    super.onClose();
  }

  // Method to select date of birth
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF151515),
            ),
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Format as DD/MM/YYYY
      final String formattedDate =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      dobController.text = formattedDate;
    }
  }

  // Fields for signup flow
  final RxString signupEmail = "".obs;
  final RxString signupPin = "".obs;

  void prepareProfileSetup({required String email, required String name}) {
    emailController.text = email;
    nameController.text = name;
    dobController.text = "";
    referralController.text = "";
  }

  // Send signup verification & initiate registration API call and save to Firestore
  Future<bool> initiateEmailSignUp({
    required String email,
    required String username,
    required String dob,
    required String password,
    String? referralCode,
  }) async {
    isLoading.value = true;
    final String cleanEmail = email.trim().toLowerCase();
    User? firebaseUser;
    try {
      // Step 1: Create user in Firebase Auth
      log("Creating user in Firebase Auth: $cleanEmail");
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception("Failed to create Firebase Auth user.");
      }

      // Step 2: Call Backend API to register user
      final Map<String, dynamic> body = {
        "name": username,
        "email": cleanEmail,
        "password": password,
        if (referralCode != null && referralCode.isNotEmpty)
          "referralCode": referralCode,
      };

      log("Calling register API with body: $body");
      AuthModel responseModel = await AuthRepo.registerUser(body);
      log("Register API Response: ${responseModel.toJson()}");

      if (responseModel.isSuccess == true) {
        // Step 3: Store signup details in Firestore database
        await FirebaseFirestore.instance.collection('users').doc(cleanEmail).set({
          "email": cleanEmail,
          "name": username,
          "birthDate": dob,
          "password": password,
          "referralCode": referralCode ?? "",
          "isVerified": false,
          "token": "",
          "createdAt": FieldValue.serverTimestamp(),
        });
        log("Saved pending user to Firestore under document ID: $cleanEmail");

        // Step 4: Send Firebase verification email
        await firebaseUser.sendEmailVerification();
        log("Verification email sent successfully to $cleanEmail");

        signupEmail.value = cleanEmail;
        await SharedPrefHelper.setString("email", cleanEmail);
        return true;
      } else {
        log("Backend registration failed. Rolling back Firebase user...");
        await firebaseUser.delete().catchError((err) {
          log("Failed to delete Firebase user during rollback: $err");
        });
        Get.snackbar(
          "Registration Failed",
          responseModel.message ?? "Something went wrong on the server",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        return false;
      }
    } on FirebaseAuthException catch (e) {
      log("Firebase Auth exception during registration: ${e.code} - ${e.message}");
      if (firebaseUser != null) {
        await firebaseUser.delete().catchError((err) {
          log("Failed to clean up Firebase user: $err");
        });
      }
      String errorMsg = "Registration failed.";
      if (e.code == "email-already-in-use") {
        errorMsg = "This email is already registered.";
      } else if (e.code == "weak-password") {
        errorMsg = "The password is too weak. Must be at least 6 characters.";
      } else if (e.code == "invalid-email") {
        errorMsg = "The email address is invalid.";
      } else if (e.code == "network-request-failed") {
        errorMsg = "Network request failed. Please check your internet connection.";
      }
      Get.snackbar(
        "Registration Failed",
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return false;
    } catch (e) {
      log("Error during registration: $e");
      if (firebaseUser != null) {
        await firebaseUser.delete().catchError((err) {
          log("Failed to clean up Firebase user: $err");
        });
      }
      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void startVerificationListener(String email) {
    _verificationTimer?.cancel();
    _verificationSubscription?.cancel();
    final String cleanEmail = email.trim().toLowerCase();

    log("Starting email verification polling for: $cleanEmail");

    int consecutiveErrors = 0;
    const int pollingIntervalSeconds = 4;

    _verificationTimer = Timer.periodic(
      const Duration(seconds: pollingIntervalSeconds),
      (timer) async {
        try {
          var user = FirebaseAuth.instance.currentUser;
          
          if (user == null) {
            final String emailVal = emailController.text.trim();
            final String passVal = passwordController.text.trim();
            if (emailVal.isNotEmpty && passVal.isNotEmpty) {
              log("Verification Listener: User session null. Attempting fallback sign in...");
              try {
                final creds = await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: emailVal,
                  password: passVal,
                );
                user = creds.user;
              } catch (signInErr) {
                log("Verification Listener fallback sign in failed: $signInErr");
              }
            }
          }

          if (user == null) {
            consecutiveErrors++;
            log("Verification Listener: No active user session (Attempt $consecutiveErrors)");
            if (consecutiveErrors >= 5) {
              timer.cancel();
              Get.snackbar(
                "Verification Paused",
                "Session lost. Please log in or try resending verification email.",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                colorText: Colors.white,
              );
            }
            return;
          }

          // Reload Firebase Auth user state
          await user.reload().timeout(const Duration(seconds: 8));
          
          consecutiveErrors = 0;

          final updatedUser = FirebaseAuth.instance.currentUser;
          if (updatedUser != null && updatedUser.emailVerified) {
            timer.cancel();
            log("Verification Listener: User verified successfully!");

            // Update Firestore database
            await FirebaseFirestore.instance
                .collection("users")
                .doc(cleanEmail)
                .update({
              "isVerified": true,
              "token": "",
            });
            log("Saved verified status to Firestore for: $cleanEmail");

            // Sign out to clean up session and prevent auto login
            await FirebaseAuth.instance.signOut();
            log("Signed out Firebase Auth session to prevent auto-login");

            // Show custom success dialog / popup
            _showSuccessPopup();
          }
        } on FirebaseAuthException catch (e) {
          consecutiveErrors++;
          log("Verification Listener: FirebaseAuthException (Attempt $consecutiveErrors): ${e.code} - ${e.message}");
          
          if (e.code == 'network-request-failed') {
            if (consecutiveErrors >= 5) {
              timer.cancel();
              Get.snackbar(
                "Network Error",
                "Verification check failed repeatedly. Please check your internet connection.",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                colorText: Colors.white,
              );
            }
          } else {
            if (consecutiveErrors >= 5) {
              timer.cancel();
            }
          }
        } catch (e) {
          consecutiveErrors++;
          log("Verification Listener: Unexpected error (Attempt $consecutiveErrors): $e");
          if (consecutiveErrors >= 5) {
            timer.cancel();
          }
        }
      },
    );
  }

  Future<void> resendVerificationEmail() async {
    try {
      var user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        final String emailVal = emailController.text.trim();
        final String passVal = passwordController.text.trim();
        if (emailVal.isNotEmpty && passVal.isNotEmpty) {
          log("Resend: User session null. Attempting fallback sign in...");
          try {
            final creds = await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: emailVal,
              password: passVal,
            );
            user = creds.user;
          } catch (signInErr) {
            log("Resend fallback sign in failed: $signInErr");
          }
        }
      }

      if (user != null) {
        await user.sendEmailVerification().timeout(const Duration(seconds: 10));
        Get.snackbar(
          "Email Sent",
          "Verification email has been resent successfully.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          "No user session found. Please sign up or sign in.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    } on FirebaseAuthException catch (e) {
      log("Error resending verification email: ${e.code} - ${e.message}");
      String errorMsg = "Failed to resend verification email.";
      if (e.code == 'network-request-failed') {
        errorMsg = "Network connection failed. Please check your internet connection.";
      }
      Get.snackbar(
        "Error",
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      log("Error resending verification email: $e");
      Get.snackbar(
        "Error",
        "Failed to resend verification email: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  void _showSuccessPopup() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),
              const CommonText.h2(
                "Email Verified",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              CommonText.body(
                "Tamaroo account successfully verify thai gayu chhe!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Redirect to Sign In screen after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      isSignUpMode.value = false;
      Get.offAll(() => const EmailSignUpScreen());
    });
  }

  // Verify signup OTP locally
  Future<bool> verifySignupOtp(String otp) async {
    isLoading.value = true;
    try {
      if (otp.length == 4) {
        return true;
      } else {
        Get.snackbar(
          "Invalid OTP",
          "OTP must be 4 digits",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        return false;
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Complete Email/Password Sign Up (calls update-profile and set-password)
  Future<bool> completeEmailSignup({
    required String username,
    required String dob,
    required String password,
    required String confirmPassword,
    String? referralCode,
  }) async {
    isLoading.value = true;
    try {
      // Step 1: Set Password first (using registration token)
      final String token = SharedPrefHelper.getString("token") ?? "";
      final Map<String, dynamic> passwordBody = {
        "token": token,
        "password": password,
        "confirmPassword": confirmPassword,
      };

      log("Calling set-password API with body: $passwordBody");
      AuthModel passwordResponse = await AuthRepo.setPassword(passwordBody);
      log("Set Password API Response: ${passwordResponse.toJson()}");

      if (passwordResponse.isSuccess == true) {
        // Save the new token (accessToken) and name/email
        if (passwordResponse.data?.token != null) {
          await SharedPrefHelper.setString("token", passwordResponse.data!.token!);
        }
        if (passwordResponse.data?.refreshToken != null) {
          await SharedPrefHelper.setString("refreshToken", passwordResponse.data!.refreshToken!);
        }
        await SharedPrefHelper.setString("email", signupEmail.value);
        await SharedPrefHelper.setString("name", username);

        // Step 2: Now that we are authenticated, update Profile Details
        final Map<String, dynamic> updateBody = {
          "name": username,
          "birthDate": dob,
        };

        log("Calling update-profile API with body: $updateBody");
        AuthModel updateResponse = await AuthRepo.updateProfile(updateBody);
        if (updateResponse.isSuccess != true) {
          log("Warning: Profile update failed: ${updateResponse.message}");
        }

        // Upload FCM token
        if (Get.isRegistered<NotificationService>()) {
          Get.find<NotificationService>().uploadFcmToken();
        }

        await fetchCurrentUserDetails();

        Get.snackbar(
          "Success",
          "Account setup completed successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
        );

        Get.offAll(() => const HomeScreenView());
        return true;
      } else {
        Get.snackbar(
          "Failed to Set Password",
          passwordResponse.message ?? "Something went wrong while setting password",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      log("Error completing email signup: $e");
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

  // Complete Google Sign Up (for new Google users)
  Future<void> completeGoogleSignup({
    required String username,
    required String dob,
    String? referralCode,
  }) async {
    isLoading.value = true;
    try {
      final Map<String, dynamic> body = {
        "name": username,
        "birthDate": dob,
      };

      AuthModel responseModel = await AuthRepo.updateProfile(body);

      if (responseModel.isSuccess == true) {
        await SharedPrefHelper.setString("name", username);
        await fetchCurrentUserDetails();

        Get.snackbar(
          "Success",
          "Profile updated successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
        );

        final bool isMpinSet = SharedPrefHelper.getBool("hasMpin") ?? false;
        if (isMpinSet) {
          Get.offAll(() => const MpinUnlockScreen());
        } else {
          Get.offAll(() => const HomeScreenView());
        }
      } else {
        Get.snackbar(
          "Failed",
          responseModel.message ?? "Failed to update profile",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log("Error completing Google profile setup: $e");
      Get.snackbar(
        "Error",
        "Something went wrong",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Handle Google Login logic
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      apiResponse = ApiResponse.loading(message: 'Google Sign-In Loading...');

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '924129661846-0e5hp4vm0pu50ngoq9gii7s5q328anv1.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

      // Force showing account selection dialog listing all email accounts
      await googleSignIn.signOut().catchError((e) => null);

      // Trigger the sign-in flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        isLoading.value = false;
        apiResponse = ApiResponse.initial(message: 'Sign-In cancelled');
        return;
      }

      // Obtain authentication details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      log(
        "Google user signed in: ${googleUser.email}, googleId: ${googleUser.id}",
      );

      // Sign in to Firebase Auth using Google credentials
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      log("Signing in to Firebase with Google credentials...");
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception("Firebase sign-in failed. User is null.");
      }

      // Retrieve Firebase ID Token
      final String? firebaseIdToken = await firebaseUser.getIdToken();
      log(
        "Firebase user signed in: ${firebaseUser.email}, uid: ${firebaseUser.uid}",
      );

      final Map<String, dynamic> body = {
        "googleId": googleUser.id,
        "email": googleUser.email,
        "name": googleUser.displayName ?? "",
        if (googleAuth.idToken != null) "idToken": googleAuth.idToken,
        if (firebaseIdToken != null) "firebaseIdToken": firebaseIdToken,
      };

      AuthModel responseModel = await AuthRepo.googleLogin(body);

      if (responseModel.isSuccess == true) {
        log(
          "Google Login Response User: ${responseModel.data?.user?.toJson()}",
        );
        // Save token & userId to SharedPreferences
        if (responseModel.data?.token != null) {
          await SharedPrefHelper.setString("token", responseModel.data!.token!);
        }
        if (responseModel.data?.refreshToken != null) {
          await SharedPrefHelper.setString("refreshToken", responseModel.data!.refreshToken!);
        }
        if (responseModel.data?.user?.sId != null) {
          await SharedPrefHelper.setString(
            "userId",
            responseModel.data!.user!.sId!,
          );
        }
        if (responseModel.data?.user?.name != null) {
          await SharedPrefHelper.setString(
            "name",
            responseModel.data!.user!.name!,
          );
        }
        if (responseModel.data?.user?.email != null) {
          await SharedPrefHelper.setString(
            "email",
            responseModel.data!.user!.email!,
          );
        }

        // Fetch complete current user details to get updated isMpinSet status
        await fetchCurrentUserDetails();
        final bool isMpinSet = SharedPrefHelper.getBool("hasMpin") ?? false;
        log("Evaluated isMpinSet: $isMpinSet");

        // Upload FCM token on successful login
        if (Get.isRegistered<NotificationService>()) {
          Get.find<NotificationService>().uploadFcmToken();
        }

        apiResponse = ApiResponse.complete(responseModel);

        Get.snackbar(
          "Success",
          responseModel.message ?? "Logged in successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
        );

        final user = responseModel.data?.user;
        final bool isProfileIncomplete = user?.birthDate == null || user!.birthDate!.trim().isEmpty;

        if (isProfileIncomplete) {
          prepareProfileSetup(
            email: user?.email ?? "",
            name: user?.name ?? "",
          );
          Get.offAll(() => const ProfileSetupScreen(isGoogleUser: true));
        } else {
          if (isMpinSet) {
            Get.offAll(() => const MpinUnlockScreen());
          } else {
            Get.offAll(() => const HomeScreenView());
          }
        }
      } else {
        apiResponse = ApiResponse.error(message: responseModel.message);
        Get.snackbar(
          "Login Failed",
          responseModel.message ?? "Something went wrong",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log(
        "Google Sign-In error ============================================================ $e",
      );
      apiResponse = ApiResponse.error(message: e.toString());
      Get.snackbar(
        "Error",
        "Something went wrong",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Handle Logout logic
  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Call Logout API
      AuthModel responseModel = await AuthRepo.logoutUser();

      // Clear token & userId from SharedPreferences
      await SharedPrefHelper.remove("token");
      await SharedPrefHelper.remove("refreshToken");
      await SharedPrefHelper.remove("userId");
      await SharedPrefHelper.remove("email");
      await SharedPrefHelper.remove("name");
      await SharedPrefHelper.remove("hasMpin");

      MpinController.isSessionUnlocked = false;

      // Disconnect socket if initialized
      if (Get.isRegistered<SocketService>()) {
        Get.find<SocketService>().disconnectSocket();
      }

      // Clear text controllers and reactive states
      nameController.clear();
      emailController.clear();
      dobController.clear();
      referralController.clear();
      pinController.clear();
      passwordController.clear();
      isUsernameUnique.value = null;
      isCheckingUsername.value = false;
      signupEmail.value = "";
      signupPin.value = "";
      obscurePin.value = true;
      obscurePassword.value = true;
      isSignUpMode.value = true;

      // Clear OTP/PIN related controllers in MpinController if registered
      if (Get.isRegistered<MpinController>()) {
        final mpinCtrl = Get.find<MpinController>();
        mpinCtrl.emailController.clear();
        mpinCtrl.otpController.clear();
        mpinCtrl.newPasswordController.clear();
        mpinCtrl.confirmPasswordController.clear();
        mpinCtrl.currentInput.value = "";
        mpinCtrl.firstPin.value = "";
        mpinCtrl.isConfirming.value = false;
      }

      Get.snackbar(
        "Logged Out",
        responseModel.message ?? "Logged out successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withValues(alpha: 0.9),
        colorText: Colors.white,
      );

      // Navigate back to LoginScreen
      Get.offAll(() => const LoginScreenView());
    } catch (e) {
      log("Logout error: $e");
      // Fallback: clear local session to ensure user is not locked in on failure
      await SharedPrefHelper.remove("token");
      await SharedPrefHelper.remove("refreshToken");
      await SharedPrefHelper.remove("userId");
      await SharedPrefHelper.remove("email");
      await SharedPrefHelper.remove("name");
      await SharedPrefHelper.remove("hasMpin");
      MpinController.isSessionUnlocked = false;
      if (Get.isRegistered<SocketService>()) {
        Get.find<SocketService>().disconnectSocket();
      }

      // Clear text controllers and reactive states on fallback
      nameController.clear();
      emailController.clear();
      dobController.clear();
      referralController.clear();
      pinController.clear();
      passwordController.clear();
      isUsernameUnique.value = null;
      isCheckingUsername.value = false;
      signupEmail.value = "";
      signupPin.value = "";
      obscurePin.value = true;
      obscurePassword.value = true;
      isSignUpMode.value = true;

      if (Get.isRegistered<MpinController>()) {
        final mpinCtrl = Get.find<MpinController>();
        mpinCtrl.emailController.clear();
        mpinCtrl.otpController.clear();
        mpinCtrl.newPasswordController.clear();
        mpinCtrl.confirmPasswordController.clear();
        mpinCtrl.currentInput.value = "";
        mpinCtrl.firstPin.value = "";
        mpinCtrl.isConfirming.value = false;
      }

      Get.offAll(() => const LoginScreenView());
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch current user details
  Future<void> fetchCurrentUserDetails() async {
    try {
      AuthModel responseModel = await AuthRepo.getMe();
      log(
        "fetchCurrentUserDetails raw user data: ${responseModel.data?.user?.toJson()}",
      );
      if (responseModel.isSuccess == true) {
        apiResponse = ApiResponse.complete(responseModel);
        log("Fetched current user: ${responseModel.data?.user?.name}");
        if (responseModel.data?.user?.name != null) {
          await SharedPrefHelper.setString(
            "name",
            responseModel.data!.user!.name!,
          );
        }
        if (responseModel.data?.user?.email != null) {
          await SharedPrefHelper.setString(
            "email",
            responseModel.data!.user!.email!,
          );
        }
        await SharedPrefHelper.setBool(
          "hasMpin",
          responseModel.data?.user?.isMpinSet == true,
        );
        log(
          "Saved hasMpin to shared preferences: ${responseModel.data?.user?.isMpinSet == true}",
        );
      }
    } catch (e) {
      log("Error fetching user details: $e");
    }
  }

  // Change user password
  Future<void> changeUserPassword(String newPassword) async {
    if (newPassword.isEmpty || newPassword.length < 8) {
      Get.snackbar(
        "Invalid Password",
        "Password must be at least 8 characters long",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final Map<String, dynamic> body = {
        "newPassword": newPassword,
        "oldPassword": "",
      };

      AuthModel responseModel = await AuthRepo.changePassword(body);

      if (responseModel.isSuccess == true) {
        Get.snackbar(
          "Success",
          responseModel.message ?? "Password updated successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        Get.back(); // Navigate back
      } else {
        Get.snackbar(
          "Error",
          responseModel.message ?? "Failed to change password",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log("Error changing password: $e");
      Get.snackbar(
        "Error",
        "Something went wrong",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Create user MPIN
  Future<bool> createMpin(String mpin) async {
    if (mpin.isEmpty || mpin.length != 4) {
      Get.snackbar(
        "Invalid MPIN",
        "MPIN must be 4 digits",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return false;
    }

    try {
      isLoading.value = true;

      final Map<String, dynamic> body = {"mpin": mpin};

      // Attempt setMpin first, fall back to createMpin
      AuthModel responseModel = await AuthRepo.setMpin(body);

      if (responseModel.isSuccess == true) {
        await SharedPrefHelper.setBool("hasMpin", true);
        Get.snackbar(
          "Success",
          responseModel.message ?? "MPIN created successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        return true;
      } else {
        // Fallback
        AuthModel fallbackModel = await AuthRepo.createMpin(body);
        if (fallbackModel.isSuccess == true) {
          await SharedPrefHelper.setBool("hasMpin", true);
          Get.snackbar(
            "Success",
            fallbackModel.message ?? "MPIN created successfully!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.9),
            colorText: Colors.white,
          );
          return true;
        }
        Get.snackbar(
          "Error",
          fallbackModel.message ??
              responseModel.message ??
              "Failed to create MPIN",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      log("Error creating MPIN: $e");
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

  // Method to login with Email and MPIN directly (for existing users via email path)
  Future<void> loginWithEmailMpin(String email, String mpin) async {
    isLoading.value = true;
    final String cleanEmail = email.trim().toLowerCase();
    try {
      final Map<String, dynamic> body = {
        "email": cleanEmail,
        "mpin": mpin,
      };
      AuthModel responseModel = await AuthRepo.loginMpin(body);
      if (responseModel.isSuccess == true) {
        if (responseModel.data?.token != null) {
          await SharedPrefHelper.setString("token", responseModel.data!.token!);
        }
        if (responseModel.data?.refreshToken != null) {
          await SharedPrefHelper.setString("refreshToken", responseModel.data!.refreshToken!);
        }
        if (responseModel.data?.user?.sId != null) {
          await SharedPrefHelper.setString("userId", responseModel.data!.user!.sId!);
        }
        await SharedPrefHelper.setString("email", cleanEmail);
        if (responseModel.data?.user?.name != null) {
          await SharedPrefHelper.setString("name", responseModel.data!.user!.name!);
        }
        await SharedPrefHelper.setBool("hasMpin", true);

        // Upload FCM token
        if (Get.isRegistered<NotificationService>()) {
          Get.find<NotificationService>().uploadFcmToken();
        }

        Get.snackbar(
          "Success",
          "Logged in successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
        );

        Get.offAll(() => const HomeScreenView());
      } else {
        Get.snackbar(
          "Login Failed",
          responseModel.message ?? "Invalid email or PIN",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log("Error logging in with email and mpin: $e");
      Get.snackbar(
        "Error",
        "Something went wrong",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithEmailPassword(String email, String password) async {
    isLoading.value = true;
    final String cleanEmail = email.trim().toLowerCase();
    try {
      log("Signing in with Firebase Auth: $cleanEmail");
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception("Failed to get Firebase Auth user.");
      }

      // Check if user email is verified
      if (!firebaseUser.emailVerified) {
        await firebaseUser.sendEmailVerification();
        signupEmail.value = cleanEmail;
        await SharedPrefHelper.setString("email", cleanEmail);
        
        Get.snackbar(
          "Email Not Verified",
          "A verification link has been sent to your email. Please verify before logging in.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        
        startVerificationListener(cleanEmail);
        Get.to(() => const OtpVerificationScreen());
        return;
      }

      // Retrieve user data from Firestore
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(cleanEmail)
          .get();

      String username = firebaseUser.displayName ?? "";
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data['name'] != null) {
          username = data['name'].toString();
        }
      }

      final String? firebaseToken = await firebaseUser.getIdToken();
      log("Firebase ID Token obtained: $firebaseToken");

      if (firebaseToken == null) {
        throw Exception("Failed to retrieve Firebase ID token.");
      }

      // Call backend to verify Firebase Token and issue JWT
      final String? fcmToken = SharedPrefHelper.getString("fcmToken");
      final Map<String, dynamic> loginBody = {
        "firebaseToken": firebaseToken,
        if (fcmToken != null && fcmToken.isNotEmpty) "deviceId": fcmToken,
      };

      final AuthModel responseModel = await AuthRepo.firebaseLogin(loginBody);

      if (responseModel.isSuccess == true) {
        log("Backend Firebase Login Response: ${responseModel.data?.toJson()}");

        // Save backend JWT token, email, name, and userId locally
        if (responseModel.data?.token != null) {
          await SharedPrefHelper.setString("token", responseModel.data!.token!);
        } else {
          // Fallback if token is null
          await SharedPrefHelper.setString("token", firebaseToken);
        }
        if (responseModel.data?.refreshToken != null) {
          await SharedPrefHelper.setString("refreshToken", responseModel.data!.refreshToken!);
        }

        if (responseModel.data?.user?.sId != null) {
          await SharedPrefHelper.setString("userId", responseModel.data!.user!.sId!);
        }
        await SharedPrefHelper.setString("email", responseModel.data?.user?.email ?? cleanEmail);
        
        final String backendUsername = responseModel.data?.user?.name ?? username;
        if (backendUsername.isNotEmpty) {
          await SharedPrefHelper.setString("name", backendUsername);
        }
      } else {
        throw Exception(responseModel.message ?? "Backend verification failed.");
      }

      // Update Firestore user document with current token
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cleanEmail)
          .update({
        "isVerified": true,
        "token": SharedPrefHelper.getString("token") ?? firebaseToken,
      });

      // Upload FCM token
      if (Get.isRegistered<NotificationService>()) {
        Get.find<NotificationService>().uploadFcmToken();
      }

      await fetchCurrentUserDetails();

      Get.snackbar(
        "Success",
        "Logged in successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
      );

      Get.offAll(() => const HomeScreenView());
    } on FirebaseAuthException catch (e) {
      log("Firebase Auth sign in failed: ${e.code} - ${e.message}");
      String errorMsg = "Login failed.";
      if (e.code == "user-not-found" || e.code == "invalid-credential" || e.code == "wrong-password") {
        errorMsg = "Invalid email or password.";
      } else if (e.code == "network-request-failed") {
        errorMsg = "Network connection failed. Please check your internet connection.";
      }
      Get.snackbar(
        "Login Failed",
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      log("Error logging in: $e");
      String errorMsg = e.toString().replaceAll("Exception: ", "");
      Get.snackbar(
        "Error",
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}



