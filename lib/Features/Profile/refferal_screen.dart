import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../Utility/black_card.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_copy_clipboard.dart';
import '../../Utility/app_snackbar.dart';
import '../../Utility/common_next_arrow_icon.dart';
import '../../Utility/common_text.dart';
import '../../Utility/custom_appbar.dart';
import '../../Utility/font_style.dart';
import '../../Utility/image_const.dart';
import '../../Utility/yellow_card.dart';
import 'invite_friends_screen.dart';
import 'referral_controller.dart';
import 'referral_members_screen.dart';
import 'referral_model.dart';
import '../../Service/Ads/native_ads_service.dart';

class ReferralScreenView extends StatelessWidget {
  const ReferralScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final ReferralController controller = Get.put(ReferralController());

    return Scaffold(
      backgroundColor: CommonColor.background,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Golden gradient background ──────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.9,
                child: Image.asset(
                  ImageConst.goldenShadowImage,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),

            Positioned.fill(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // header space
                    const SizedBox(height: 16),

                    // ── AppBar ──────────────────────────────────────────────
                    CustomAppBar(
                      title: "Referral Program",
                      fontSize: 22,
                      actions: [
                        GestureDetector(
                          onTap: () => Get.to(
                            () => const ReferralMembersScreen(),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 300),
                          ),
                          child: SvgPicture.asset(
                            ImageConst.profileUser,
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Invite to your friends and\nget a extra coins.",
                      textAlign: TextAlign.center,
                      style: CommonFontStyles.heading1,
                    ),

                    const SizedBox(height: 32),

                    // ── Invite Friends Button ───────────────────────────────
                    YellowCard(
                      width: 370,
                      height: 50,
                      borderRadius: 30,
                      onTap: () {
                        Get.to(
                          () => const InviteFriendsScreen(),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                      child: const Text(
                        "Invite friends",
                        style: CommonFontStyles.heading3,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Copy Referral Link (from API) ───────────────────────
                    Obx(() {
                      final isLoading = controller.isLoadingInfo.value;
                      final link = controller.displayReferralLink;

                      return InkWell(
                        onTap: isLoading
                            ? null
                            : () {
                                CommonCopyClipboard.copy(
                                  context,
                                  link,
                                  message: "Referral link copied",
                                );
                              },
                        borderRadius: BorderRadius.circular(30),
                        child: GradientBorderContainer(
                          width: 370,
                          height: 50,
                          borderRadius: 30,
                          alignment: Alignment.center,
                          child: isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: CommonColor.orange,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      ImageConst.copyIcon,
                                      width: 18,
                                      height: 18,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Referral link",
                                      style: CommonFontStyles.heading3,
                                    ),
                                  ],
                                ),
                        ),
                      );
                    }),

                    const SizedBox(height: 26),

                    // ── Total Rewards Card (from /referrals/info) ───────────
                    Obx(() {
                      final isLoading = controller.isLoadingInfo.value;
                      final totalRewards = controller.displayTotalRewards;
                      final totalReferrals = controller.totalReferralCount;

                      return GradientBorderContainer(
                        width: 371,
                        height: 80,
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Total rewards",
                                    style: CommonFontStyles.small.copyWith(
                                      color: const Color(0xFFB0B0B0),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  isLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: CommonColor.orange,
                                          ),
                                        )
                                      : Text(
                                          "$totalRewards BTC",
                                          style: CommonFontStyles.heading2
                                              .copyWith(
                                            fontSize: 20,
                                            color: CommonColor.orange,
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            // Referral count badge
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Total referred",
                                    style: CommonFontStyles.small.copyWith(
                                      color: const Color(0xFFB0B0B0),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  isLoading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: CommonColor.blue,
                                          ),
                                        )
                                      : Text(
                                          "$totalReferrals users",
                                          style: CommonFontStyles.heading3
                                              .copyWith(
                                                  color: CommonColor.blue),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // const _ReferralAdBanner(),

                    // const SizedBox(height: 24),
                    //
                    // // ── Members Section Title ───────────────────────────────
                    // const Align(
                    //   alignment: Alignment.centerLeft,
                    //   child: SizedBox(
                    //     width: 370,
                    //     child: Padding(
                    //       padding: EdgeInsets.symmetric(horizontal: 4.0),
                    //       child: Text(
                    //         "Members",
                    //         style: CommonFontStyles.heading1,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    //
                    // const SizedBox(height: 12),
                    //
                    // // ── Referred Users List (from /referrals/users) ─────────
                    // Obx(() {
                    //   if (controller.isLoadingUsers.value) {
                    //     return const Padding(
                    //       padding: EdgeInsets.symmetric(vertical: 24),
                    //       child: Center(
                    //         child: CircularProgressIndicator(
                    //             color: CommonColor.orange),
                    //       ),
                    //     );
                    //   }
                    //
                    //   final users = controller.referredUsers;
                    //
                    //   if (users.isEmpty) {
                    //     return Padding(
                    //       padding: const EdgeInsets.symmetric(vertical: 24),
                    //       child: Center(
                    //         child: CommonText.body(
                    //           "No referred members yet",
                    //           style: const TextStyle(color: Colors.grey),
                    //         ),
                    //       ),
                    //     );
                    //   }
                    //
                    //   return SizedBox(
                    //     width: 370,
                    //     child: Column(
                    //       children: users
                    //           .map((user) => _buildMemberList(
                    //                 name: user.name,
                    //                 statusText: user.isMiningActive
                    //                     ? "Active Min"
                    //                     : "Inactive",
                    //                 durationText: user.miningDuration,
                    //                 isActive: user.isMiningActive,
                    //               ))
                    //           .toList(),
                    //     ),
                    //   );
                    // }),
                    //
                    const SizedBox(height: 2),
                    const Center(child: AppNativeAd()),
                    const SizedBox(height: 24),

                    // ── Rewards Breakdown Section ───────────────────────────
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 370,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            "Reward History",
                            style: CommonFontStyles.heading1,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Rewards List (from /referrals/rewards) ──────────────
                    Obx(() {
                      if (controller.isLoadingRewards.value) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: CircularProgressIndicator(
                                color: CommonColor.orange),
                          ),
                        );
                      }

                      final rewards = controller.referralRewards;

                      if (rewards.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: CommonText.body(
                              "No rewards earned yet",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }

                      return SizedBox(
                        width: 370,
                        child: Column(
                          children: rewards
                              .map((reward) => _buildRewardItem(reward))
                              .toList(),
                        ),
                      );
                    }),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Member Row Widget ──────────────────────────────────────────────────────
  Widget _buildMemberList({
    required String name,
    required String statusText,
    required String durationText,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? CommonColor.darkGreen : CommonColor.darkRed,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              ImageConst.profileUser,
              colorFilter: ColorFilter.mode(
                isActive ? CommonColor.green : CommonColor.red,
                BlendMode.srcIn,
              ),
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name, style: CommonFontStyles.heading3),
                const SizedBox(height: 2),
                Text(
                  statusText,
                  style: CommonFontStyles.body.copyWith(
                    color: isActive
                        ? CommonColor.green
                        : const Color(0xFF6E6E6E),
                  ),
                ),
              ],
            ),
          ),

          Text(durationText, style: CommonFontStyles.heading3),
        ],
      ),
    );
  }

  // ─── Reward Row Widget ──────────────────────────────────────────────────────
  Widget _buildRewardItem(ReferralReward reward) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CommonColor.blue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: CommonColor.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reward.type, style: CommonFontStyles.heading3),
                const SizedBox(height: 2),
                Text(
                  "From: ${reward.fromUserName}",
                  style: CommonFontStyles.body.copyWith(
                    color: const Color(0xFF6E6E6E),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Text(
            "${reward.amount} BTC",
            style: CommonFontStyles.heading3.copyWith(
              color: CommonColor.orange,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferralAdBanner extends StatelessWidget {
  const _ReferralAdBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 371,
      height: 108,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: CommonColor.greyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.0,
        ),
      ),
      // child: Row(
      //   crossAxisAlignment: CrossAxisAlignment.center,
      //   children: [
      //     // ClipRRect(
      //     //   borderRadius: BorderRadius.circular(12),
      //     //   child: SizedBox(
      //     //     width: 90,
      //     //     height: 90,
      //     //     child: Image.asset(
      //     //       ImageConst.bitcoinImage,
      //     //       fit: BoxFit.cover,
      //     //     ),
      //     //   ),
      //     // ),
      //     // const SizedBox(width: 10),
      //     // Expanded(
      //     //   child: Column(
      //     //     crossAxisAlignment: CrossAxisAlignment.start,
      //     //     mainAxisAlignment: MainAxisAlignment.center,
      //     //     children: [
      //     //       const Text(
      //     //         "BTC Mining Cloud Bitcoin Min...",
      //     //         style: TextStyle(
      //     //           fontWeight: FontWeight.normal,
      //     //           color: Colors.white,
      //     //           fontSize: 12,
      //     //         ),
      //     //         maxLines: 1,
      //     //         overflow: TextOverflow.ellipsis,
      //     //       ),
      //     //       const SizedBox(height: 2),
      //     //       Row(
      //     //         children: [
      //     //           Container(
      //     //             padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      //     //             decoration: BoxDecoration(
      //     //               border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      //     //               borderRadius: BorderRadius.circular(3),
      //     //             ),
      //     //             child: Text(
      //     //               "AD",
      //     //               style: TextStyle(
      //     //                 color: Colors.white.withValues(alpha: 0.6),
      //     //                 fontSize: 7,
      //     //                 fontWeight: FontWeight.normal,
      //     //               ),
      //     //             ),
      //     //           ),
      //     //           const SizedBox(width: 6),
      //     //           Row(
      //     //             children: List.generate(5, (index) => const Icon(
      //     //               Icons.star,
      //     //               color: Color(0xFFF49518),
      //     //               size: 10,
      //     //             )),
      //     //           ),
      //     //         ],
      //     //       ),
      //     //       const SizedBox(height: 2),
      //     //       Text(
      //     //         "Now you can! Dive into the world of cryptocur...",
      //     //         style: TextStyle(
      //     //           color: Colors.white.withValues(alpha: 0.6),
      //     //           fontSize: 9,
      //     //         ),
      //     //         maxLines: 1,
      //     //         overflow: TextOverflow.ellipsis,
      //     //       ),
      //     //       const SizedBox(height: 6),
      //     //       GestureDetector(
      //     //         onTap: () {
      //     //           AppSnackbar.success("Installation started!");
      //     //         },
      //     //         child: Container(
      //     //           width: double.infinity,
      //     //           height: 26,
      //     //           decoration: BoxDecoration(
      //     //             color: CommonColor.blue,
      //     //             borderRadius: BorderRadius.circular(13),
      //     //           ),
      //     //           alignment: Alignment.center,
      //     //           child: const Text(
      //     //             "Install",
      //     //             style: TextStyle(
      //     //               color: Colors.white,
      //     //               fontWeight: FontWeight.normal,
      //     //               fontSize: 11,
      //     //             ),
      //     //           ),
      //     //         ),
      //     //       ),
      //     //     ],
      //     //   ),
      //     // ),
      //   ],
      // ),
    );
  }
}
