import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../Utility/black_card.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_text.dart';
import '../../Utility/font_style.dart';
import '../../Utility/image_const.dart';
import 'referral_controller.dart';

import 'dart:developer';

class ReferralMembersScreen extends StatefulWidget {
  const ReferralMembersScreen({super.key});

  @override
  State<ReferralMembersScreen> createState() => _ReferralMembersScreenState();
}

class _ReferralMembersScreenState extends State<ReferralMembersScreen> {
  final ReferralController controller = Get.find<ReferralController>();

  @override
  void initState() {
    super.initState();
    // Fetch fresh members data when this screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      log("API CALLING ============================= ReferralMembersScreen opened: fetching referred users...");
      controller.fetchReferredUsers();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: CommonColor.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: CommonColor.darkGray,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Members",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  Obx(() {
                    final count = controller.referredUsers.length;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: CommonColor.blue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: CommonColor.blue.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        "$count users",
                        style: const TextStyle(
                          color: CommonColor.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // ── Members List ───────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoadingUsers.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: CommonColor.orange),
                  );
                }

                final users = controller.referredUsers;

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.group_outlined,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No members yet",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Invite friends to grow your network",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => Divider(
                    color: Colors.white.withValues(alpha: 0.06),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _MemberTile(
                      name: user.name,
                      statusText: user.isMiningActive ? "Active Mining" : "Inactive",
                      durationText: user.miningDuration,
                      isActive: user.isMiningActive,
                      index: index,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final String name;
  final String statusText;
  final String durationText;
  final bool isActive;
  final int index;

  const _MemberTile({
    required this.name,
    required this.statusText,
    required this.durationText,
    required this.isActive,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Avatar with number badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isActive ? CommonColor.darkGreen : CommonColor.darkRed,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(
                  ImageConst.profileUser,
                  colorFilter: ColorFilter.mode(
                    isActive ? CommonColor.green : CommonColor.red,
                    BlendMode.srcIn,
                  ),
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                bottom: -2,
                right: -4,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: CommonColor.background,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive ? CommonColor.green : Colors.grey,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 14),

          // Name + Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: CommonFontStyles.heading3),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isActive ? CommonColor.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      statusText,
                      style: CommonFontStyles.body.copyWith(
                        color: isActive ? CommonColor.green : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Duration
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "Duration",
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
              const SizedBox(height: 2),
              Text(
                durationText,
                style: CommonFontStyles.heading3.copyWith(fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
