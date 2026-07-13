# Guide: Exchanging Firebase ID Token for Backend JWT

This guide provides the complete, production-ready code examples for implementing **Option 1 (Token Exchange)**. Share this file with your backend and frontend developers.

---

## Part 1: Backend Implementation (Node.js / Express)

Your backend developer needs to set up the **Firebase Admin SDK**, verify the client-side Firebase token, find or create the user in MongoDB, and sign a custom JWT token.

### 1. Install Dependencies
```bash
npm install firebase-admin jsonwebtoken
```

### 2. Controller Setup (`auth.controller.js`)
Here is the code to handle the token verification, MongoDB lookup, and custom JWT signing:

```javascript
const admin = require('firebase-admin');
const jwt = require('jsonwebtoken');
const User = require('../models/user.model'); // Replace with your actual User model path

// Initialize Firebase Admin SDK
// Make sure to download your serviceAccountKey.json from Firebase Console:
// Project Settings > Service Accounts > Generate New Private Key
const serviceAccount = require('../config/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

/**
 * Endpoint: POST /api/auth/firebase-login
 * Description: Verifies Firebase ID Token, logs in/registers user in database, and returns custom JWT.
 */
const firebaseLogin = async (req, res) => {
  try {
    const { firebaseToken } = req.body;

    if (!firebaseToken) {
      return res.status(400).json({
        success: false,
        message: 'Firebase token is required.'
      });
    }

    // Step 1: Verify the Firebase ID Token
    const decodedToken = await admin.auth().verifyIdToken(firebaseToken);
    const { email, name, picture } = decodedToken;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email not provided in Firebase token.'
      });
    }

    // Step 2: Check if user exists in your MongoDB database
    let user = await User.findOne({ email: email.toLowerCase() });

    if (!user) {
      // Step 3 (Optional): If user doesn't exist, create them (Auto-Registration)
      user = await User.create({
        email: email.toLowerCase(),
        name: name || email.split('@')[0],
        avatar: picture || '',
        isVerified: true, // Mark verified since Firebase verified the email
        createdAt: new Date()
      });
      console.log(`Auto-created new user profile for: ${email}`);
    }

    // Step 4: Generate your own backend JWT token
    // Replace 'YOUR_JWT_SECRET' and expiration with your current backend config
    const backendToken = jwt.sign(
      { id: user._id, email: user.email },
      process.env.JWT_SECRET || 'YOUR_JWT_SECRET',
      { expiresIn: '30d' }
    );

    // Step 5: Send response back to mobile app
    return res.status(200).json({
      success: true,
      message: 'Logged in successfully!',
      data: {
        token: backendToken,
        user: {
          id: user._id,
          name: user.name,
          email: user.email
        }
      }
    });

  } catch (error) {
    console.error('Firebase token verification failed:', error);
    return res.status(401).json({
      success: false,
      message: 'Token verification failed.',
      error: error.message
    });
  }
};

module.exports = {
  firebaseLogin
};
```

---

## Part 2: Frontend Implementation (Flutter)

Here is the Dart code to implement in `AuthController` to sign in with Firebase, fetch the ID token, and exchange it with the backend API.

### 1. Add API Endpoint Constant (`api_const.dart`)
Add this line to your api constants file:
```dart
static const String firebaseLoginApi = "/auth/firebase-login";
```

### 2. Exchange Implementation (`auth_controller.dart`)
Replace your `loginWithEmailPassword` with this method:

```dart
  Future<void> loginWithEmailPassword(String email, String password) async {
    isLoading.value = true;
    final String cleanEmail = email.trim().toLowerCase();
    try {
      // Step 1: Sign in with Firebase Auth
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

      // Step 2: Validate Email Verification
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

      // Step 3: Get Firebase ID Token
      final String? firebaseToken = await firebaseUser.getIdToken();
      log("Obtained Firebase ID Token. Requesting backend login exchange...");

      // Step 4: Call Backend API to exchange token
      final Map<String, dynamic> body = {
        "firebaseToken": firebaseToken,
      };

      // Call your backend API POST handler
      var response = await ApiService().getResponse(
        apiType: APIType.aPost,
        url: "${ApiConst.baseUrl}${ApiConst.firebaseLoginApi}",
        body: body,
      );
      
      AuthModel responseModel = AuthModel.fromJson(response);

      if (responseModel.isSuccess == true && responseModel.data?.token != null) {
        final String backendToken = responseModel.data!.token!;
        final String username = responseModel.data?.user?.name ?? firebaseUser.displayName ?? "";

        log("Successfully obtained backend session token!");

        // Step 5: Save the Backend JWT locally
        await SharedPrefHelper.setString("token", backendToken);
        await SharedPrefHelper.setString("email", cleanEmail);
        if (username.isNotEmpty) {
          await SharedPrefHelper.setString("name", username);
        }
        if (responseModel.data?.user?.sId != null) {
          await SharedPrefHelper.setString("userId", responseModel.data!.user!.sId!);
        }

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
      } else {
        Get.snackbar(
          "Login Failed",
          responseModel.message ?? "Backend verification failed.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
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
      Get.snackbar(
        "Error",
        "Something went wrong during token exchange: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
```
