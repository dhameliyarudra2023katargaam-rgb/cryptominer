// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../Utility/blue_card.dart';
// import '../Utility/common_color.dart';
// import '../Utility/common_text.dart';
// import '../Utility/common_textfield.dart';
// import 'auth_controller.dart';
//
// class RegisterScreen extends StatelessWidget {
//   const RegisterScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final AuthController controller = Get.put(AuthController());
//
//     return Scaffold(
//       backgroundColor: CommonColor.background,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 30),
//
//               const CommonText.h1(
//                 "Sign up",
//                 style: TextStyle(fontSize: 34, height: 1.2),
//               ),
//               const SizedBox(height: 8),
//               const CommonText.body(
//                 "Enter your email and password to log in",
//                 style: TextStyle(color: CommonColor.greyColor),
//               ),
//               const SizedBox(height: 36),
//
//               // Full Name
//               const CommonText.body(
//                 "Full Name",
//                 style: TextStyle(color: CommonColor.greyColor),
//               ),
//               const SizedBox(height: 8),
//               CommonTextField(
//                 controller: controller.nameController,
//                 hintText: "Lois Becket",
//               ),
//               const SizedBox(height: 20),
//
//               // Email
//               const CommonText.body(
//                 "Email",
//                 style: TextStyle(color: CommonColor.greyColor),
//               ),
//               const SizedBox(height: 8),
//               CommonTextField(
//                 controller: controller.emailController,
//                 hintText: "Loisbecket@gmail.com",
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const SizedBox(height: 20),
//
//               // Birth of date
//               const CommonText.body(
//                 "Birth of date",
//                 style: TextStyle(color: CommonColor.greyColor),
//               ),
//               const SizedBox(height: 8),
//               CommonTextField(
//                 controller: controller.dobController,
//                 hintText: "18/03/2024",
//                 readOnly: true,
//                 onTap: () => controller.selectDate(context),
//                 suffixIcon: IconButton(
//                   icon: const Icon(
//                     Icons.calendar_today_outlined,
//                     color: CommonColor.greyColor,
//                     size: 20,
//                   ),
//                   onPressed: () => controller.selectDate(context),
//                 ),
//               ),
//               const SizedBox(height: 20),
//
//               // Referral Code
//               const CommonText.body(
//                 "Referral Code ( Optional )",
//                 style: TextStyle(color: CommonColor.greyColor),
//               ),
//               const SizedBox(height: 8),
//               CommonTextField(
//                 controller: controller.referralController,
//                 hintText: "(454) 726-0592",
//               ),
//               const SizedBox(height: 32),
//
//               // Privacy Policy Check
//               Center(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const CommonText.body(
//                       "I have Read ",
//                       style: TextStyle(color: CommonColor.greyColor),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         // Action for Privacy Policy
//                       },
//                       child: const CommonText.body(
//                         "Privacy Policy & User Agreement",
//                         style: TextStyle(
//                           color: CommonColor.blue,
//                           fontWeight: FontWeight.normal,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),
//
//               // Sign Up Button
//               Center(
//                 child: Obx(() {
//                   return BlueCard(
//                     width: 342,
//                     height: 40,
//                     onTap: controller.isLoading.value
//                         ? null
//                         : () => controller.registerUser(),
//                     child: controller.isLoading.value
//                         ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2,
//                             ),
//                           )
//                         : const CommonText.h3("Sign up"),
//                   );
//                 }),
//               ),
//               const SizedBox(height: 36),
//
//               // Toggle Sign In
//               Center(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const CommonText.body(
//                       "Already have an account? ",
//                       style: TextStyle(color: CommonColor.greyColor),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         Get.back();
//                       },
//                       child: const CommonText.body(
//                         "Log In",
//                         style: TextStyle(
//                           color: CommonColor.blue,
//                           fontWeight: FontWeight.normal,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
