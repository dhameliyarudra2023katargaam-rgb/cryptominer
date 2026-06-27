import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../Utility/black_card.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_copy_clipboard.dart';
import '../../Utility/common_textfield.dart';
import '../../Utility/custom_appbar.dart';
import '../../Utility/font_style.dart';
import '../../Utility/my_avtar.dart';
import '../../Utility/picture_path.dart';
import '../../Utility/blue_button.dart';
import '../../Auth/auth_controller.dart';
import '../../Service/storage_service.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authController = Get.find<AuthController>();
    final user = authController.apiResponse.data?.data?.user;

    _nameController.text = user?.name ?? SharedPrefHelper.getString("name") ?? "";
    _countryController.text = user?.country ?? SharedPrefHelper.getString("country") ?? "";
    _emailController.text = user?.email ?? SharedPrefHelper.getString("email") ?? "";
    _referralController.text = user?.referralCode ?? SharedPrefHelper.getString("referralCode") ?? "";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
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
            const CustomAppBar(title: "Profile", fontSize: 26),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

              const MyAvtar(radius: 60),
              const SizedBox(height: 16),

              Obx(() {
                final authController = Get.find<AuthController>();
                final name = authController.userName.value.isNotEmpty
                    ? authController.userName.value
                    : "User Name";
                return Text(name, style: CommonFontStyles.heading2);
              }),
              const SizedBox(height: 36),

              _buildProfileField(
                label: "Name",
                controller: _nameController,
              ),
              const SizedBox(height: 24),

              _buildProfileField(
                label: "Country",
                controller: _countryController,
                suffixIcon: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onTap: () {},
              ),
              const SizedBox(height: 24),

              _buildProfileField(
                label: "Email",
                controller: _emailController,
                readOnly: true,
              ),
              const SizedBox(height: 24),

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
                    PicturePath.copyIcon,
                    width: 18,
                    height: 18,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              Obx(() {
                final authController = Get.find<AuthController>();
                return BlueButton(
                  text: authController.isLoading.value ? "Saving..." : "Save",
                  width: 370,
                  height: 50,
                  onPressed: authController.isLoading.value
                      ? () {}
                      : () async {
                          final name = _nameController.text.trim();
                          final country = _countryController.text.trim();
                          if (name.isEmpty) {
                            Get.snackbar(
                              "Validation Error",
                              "Name cannot be empty",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                              colorText: Colors.white,
                            );
                            return;
                          }
                          final success = await authController.updateProfileDetails(
                            name: name,
                            country: country,
                          );
                          if (success) {
                            Get.back();
                            Get.snackbar(
                              "Success",
                              "Profile updated successfully",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green.withValues(alpha: 0.9),
                              colorText: Colors.white,
                            );
                          }
                        },
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

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
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
                        onTap: onTap,
                        style: CommonFontStyles.heading3,
                        borderless: true,
                      ),
                    ),
                    // ignore: use_null_aware_elements
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