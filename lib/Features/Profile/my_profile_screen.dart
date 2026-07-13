import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../Utility/black_card.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_copy_clipboard.dart';
import '../../Utility/common_textfield.dart';
import '../../Utility/custom_appbar.dart';
import '../../Utility/font_style.dart';
import '../../Utility/image_const.dart';
import '../../Utility/common_dialog.dart';
import '../../Utility/app_snackbar.dart';
import '../../Auth/auth_controller.dart';
import '../../Service/storage_service.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authController = Get.find<AuthController>();
    final user = authController.apiResponse.data?.data?.user;

    _emailController.text = user?.email ?? SharedPrefHelper.getString("email") ?? "";
    _referralController.text = user?.referralCode ?? SharedPrefHelper.getString("referralCode") ?? "";
  }

  @override
  void dispose() {
    _emailController.dispose();
    _referralController.dispose();
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
              // header space
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
              child: CustomAppBar(
                title: "Profile",
                fontSize: 24,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                // header space
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar Placeholder
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD9D9D9),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // User Name
                    Obx(() {
                      final authController = Get.find<AuthController>();
                      final name = authController.userName.value.isNotEmpty
                          ? authController.userName.value
                          : "User Name";
                      return Text(name, style: CommonFontStyles.heading2);
                    }),
                    const SizedBox(height: 36),

                    // Email Field (Read Only with chevron right)
                    _buildProfileField(
                      label: "Email",
                      controller: _emailController,
                      readOnly: true,
                      suffixIcon: const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Referral Code Field (Read Only with copy button)
                    _buildProfileField(
                      label: "Referral code",
                      controller: _referralController,
                      readOnly: true,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          CommonCopyClipboard.copy(
                            context,
                            _referralController.text,
                            message: "Referral code copied",
                          );
                        },
                        child: SvgPicture.asset(
                          ImageConst.copyIcon,
                          width: 18,
                          height: 18,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Delete Account Link
                    GestureDetector(
                      onTap: () {
                        CommonDialog.showConfirmation(
                          title: "Delete Account",
                          message: "Are you sure you want to delete your account? This action is permanent and cannot be undone.",
                          confirmText: "Delete",
                          confirmColor: CommonColor.red,
                          onConfirm: () {
                            AppSnackbar.success("Account deletion request submitted.");
                            final AuthController authController = Get.find<AuthController>();
                            authController.logout(showSnackbar: false);
                          },
                        );
                      },
                      child: const Text(
                        "Delete Account",
                        style: TextStyle(
                          color: CommonColor.red,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Large ad banner at bottom
                    const _ProfileAdBanner(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    Widget? suffixIcon,
    bool readOnly = false,
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
                        readOnly: readOnly,
                        style: CommonFontStyles.heading3,
                        borderless: true,
                      ),
                    ),
                    if (suffixIcon != null) suffixIcon,
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
                child: Text(label, style: CommonFontStyles.body),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAdBanner extends StatelessWidget {
  const _ProfileAdBanner();

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
