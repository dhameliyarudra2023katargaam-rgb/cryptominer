import 'package:cryptominer/Utility/image_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'black_card.dart';
import 'bottom_navigation_controller.dart';
import 'common_color.dart';
import 'common_text.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController controller = Get.find<NavigationController>();

    final List<NavigationItem> items = [
      NavigationItem(
        iconPath: ImageConst.homeIcon,
        activeIconPath: ImageConst.homeFillIcon,
        label: 'Home',
      ),
      NavigationItem(
        iconPath: ImageConst.storeIcon,
        activeIconPath: ImageConst.storeFillIcon,
        label: 'Store',
      ),
      // NavigationItem(
      //   iconPath: PicturePath.menuIcon,
      //   label: 'Menu',
      // ),
      NavigationItem(
        iconPath: ImageConst.walletIcon,
        activeIconPath: ImageConst.walletFillIcon,
        label: 'Wallet',
      ),
      NavigationItem(
        iconPath: ImageConst.myAccountIcon,
        activeIconPath: ImageConst.profileFillIcon,
        label: 'Profile',
      ),
    ];

    return Obx(() {
      return Container(
        width: 340,
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(43),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: GradientBorderContainer(
          width: 340,
          height: 72,
          borderRadius: 43,
          backgroundColor: CommonColor.bottomBarBackground,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(43),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  final isSelected = controller.selectedIndex.value == index;
                  final item = items[index];

                  return GestureDetector(
                    onTap: () {
                      controller.changeIndex(index);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSelected ? 16 : 8,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? CommonColor.orange : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            (isSelected && item.activeIconPath != null) ? item.activeIconPath! : item.iconPath,
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            CommonText.body(
                              item.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class NavigationItem {
  final String iconPath;
  final String? activeIconPath;
  final String label;

  NavigationItem({required this.iconPath, this.activeIconPath, required this.label});
}
