import 'package:cryptominer/Features/Profile/password_screen.dart';
import 'package:cryptominer/Features/Profile/refferal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'mpin_screen.dart';
import 'privacy_policy_screen.dart';

import '../../Utility/black_card.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_copy_clipboard.dart';
import '../../Utility/common_next_arrow_icon.dart';
import '../../Utility/common_text.dart';
import '../../Utility/custom_appbar.dart';
import '../../Utility/picture_path.dart';
import '../../Utility/common_dialog.dart';
import '../../Auth/auth_controller.dart';
import 'my_profile_screen.dart';

class ProfileScreenView extends StatefulWidget {
  const ProfileScreenView({super.key});

  @override
  State<ProfileScreenView> createState() => _ProfileScreenViewState();
}

class _ProfileScreenViewState extends State<ProfileScreenView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomAppBar(
            title: "Profile",
            fontSize: 26,
            leading: const SizedBox(width: 48),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          GestureDetector(
            onTap: () => Get.to(
                  () => const MyProfileScreen(),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 300),
            ),
            child: GradientBorderContainer(
              width: 371,
              height: 80,
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: CommonColor.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText.h2(
                          "User Name",
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const CommonText.body(
                              "ID: 526445",
                              style: TextStyle(
                                color: CommonColor.greyColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                CommonCopyClipboard.copy(
                                  context,
                                  "526445",
                                  message: "User ID copied",
                                );
                              },
                              child:    SvgPicture.asset(
                                PicturePath.copyIcon,
                                width: 14,
                                height: 14,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const NextArrowIcon(size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: () => Get.to(
                  () => const ReferralScreenView(),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 300),
            ),
            child: GradientBorderContainer(
              width: 370,
              height: 55,
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Row(
                children: [
                  SvgPicture.asset(
                    PicturePath.profileUser,
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 16),
                  const CommonText.h3(
                    "Referral Program",
                  ),
                  const Spacer(),
                  CommonText.small(
                    "Invite & Refer",
                    style: const TextStyle(color: CommonColor.blue),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          GradientBorderContainer(
            width: 371,
            height: 100,
            borderRadius: 16,

            child: Column(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Get.to(
                          () => const PasswordMpnScreen(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            PicturePath.profileUser,
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 16),
                          const CommonText.h3(
                            "Set Password",
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 0.5,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  color: const Color(0xFF242424),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => Get.to(
                          () => const MpinScreen(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300),
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            PicturePath.profileUser,
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 16),
                          const CommonText.h3(
                            "Create MPN",
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          GradientBorderContainer(
            width: 370,
            height: 55,
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(horizontal: 16),

            child: Row(
              children: [
                SvgPicture.asset(
                  PicturePath.languageIcon,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 16),
                const CommonText.h3(
                  "Language",
                ),
                const Spacer(),
                CommonText.small(
                  "English",
                  style: const TextStyle(color: CommonColor.blue),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          GradientBorderContainer(
            width: 371,
            height: 222,
            borderRadius: 16,
            child: Column(
              children: [
                _buildBelowAllItem(PicturePath.faqIcon, "FAQs", isFirst: true, onTap: () {}),
                _buildBelowAllDivider(),
                _buildBelowAllItem(PicturePath.supportIcon, "Support", onTap: () {}),
                _buildBelowAllDivider(),
                _buildBelowAllItem(
                  PicturePath.privacyPolicyIcon,
                  "Privacy Policy",
                  onTap: () => Get.to(() => const PrivacyPolicyScreen()),
                ),
                _buildBelowAllDivider(),
                _buildBelowAllItem(PicturePath.shareAppIcon, "Share App", onTap: () {}),
                _buildBelowAllDivider(),
                _buildBelowAllItem(
                  PicturePath.deleteAccountIcon,
                  "Delete Account",
                  isLast: true,
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              CommonDialog.showConfirmation(
                title: "Log out",
                message: "Are you sure you want to log out?",
                confirmText: "Log out",
                confirmColor: CommonColor.red,
                onConfirm: () {
                  final AuthController authController = Get.find<AuthController>();
                  authController.logout();
                },
              );
            },
            child: CommonText.h2(
              "Log out",
              style: const TextStyle(fontSize: 18, color: CommonColor.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBelowAllItem(
      String iconPath,
      String title, {
        bool isFirst = false,
        bool isLast = false,
        VoidCallback? onTap,
      }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              SvgPicture.asset(iconPath, width: 24, height: 24, fit: BoxFit.contain),
              const SizedBox(width: 16),
              CommonText.body(
                title,
                style: const TextStyle(fontSize: 15),
              ),
              const Spacer(),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBelowAllDivider() {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      color: const Color(0xFF242424),
    );
  }
}