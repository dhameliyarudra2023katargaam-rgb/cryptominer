import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../Utility/black_card.dart';
import '../../Utility/blue_button.dart';
import '../../Utility/bottom_navigation_bar.dart';
import '../../Utility/bottom_navigation_controller.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_text.dart';
import '../../Utility/font_style.dart';
import '../../Utility/image_const.dart';
import '../../Service/Ads/banner_ads_service.dart';
import '../../Service/Ads/native_ads_service.dart';
import '../../Utility/app_custom_dialog.dart';
import '../Profile/profile_screen.dart';
import '../Store/store_screen_view.dart';
import '../Wallet/wallet_screen.dart';
import '../Wallet/wallet_controller.dart';
import '../../Service/socket_service.dart';
import '../../Auth/auth_controller.dart';
import '../../Service/notification_service.dart';
import '../Notification/notification_screen.dart';
import 'home_controller.dart';
import 'maximize_profit_screen.dart';
import '../AdminMining/admin_mining_config_screen.dart';
import '../../Utility/mining_calc_helper.dart';
import '../Store/store_screen_controller.dart';

class HomeScreenView extends StatefulWidget {
  final int initialIndex;

  const HomeScreenView({super.key, this.initialIndex = 0});

  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView> {
  // Instantiate navigation controller
  final NavigationController navigationController = Get.put(
    NavigationController(),
  );

  final SocketService socketService = Get.put(SocketService());

  final HomeController homeController = Get.put(HomeController());
  final WalletController walletController = Get.put(WalletController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigationController.selectedIndex.value = widget.initialIndex;
    });
    // Fetch latest user details on load
    Get.find<AuthController>().fetchCurrentUserDetails();
    // Fetch mining status and history
    socketService.fetchMiningStatus();
    homeController.fetchDashboardData();
    socketService.fetchMiningHistory();
    // Initialize or fetch latest notifications data
    if (Get.isRegistered<NotificationService>()) {
      Get.find<NotificationService>().fetchUnreadCount();
      Get.find<NotificationService>().fetchNotifications();
      // Check and request exact alarm permission for mining notifications
      Get.find<NotificationService>().checkAndRequestExactAlarms();
    }
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) return "00:00:00";
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    return "$hoursStr:$minutesStr:$secondsStr";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColor.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 160.0),
              child: Obx(() {
                switch (navigationController.selectedIndex.value) {
                  case 0:
                    return _buildHomeDashboard();
                  case 1:
                    return const StoreScreenView();
                  case 2:
                    return const WalletScreen();
                  case 3:
                    return const ProfileScreenView();
                  default:
                    return _buildHomeDashboard();
                }
              }),
            ),

            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 100.0),
                child: AppBanner(),
              ),
            ),

            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: CustomBottomNavigationBar(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeDashboard() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [

                  const SizedBox(width: 2),
                  SvgPicture.asset(
                    ImageConst.balance,
                    width: 80,
                    height: 22,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Get.to(() => const NotificationScreen()),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                    Obx(() {
                      if (!Get.isRegistered<NotificationService>()) {
                        return const SizedBox.shrink();
                      }
                      final count =
                          Get
                              .find<NotificationService>()
                              .unreadCount
                              .value;
                      if (count > 0) {
                        return Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: CommonColor.orange,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Obx(
                                () =>
                                CommonText.body(
                                  "Basic Miner (${socketService.status.value})",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                          ),
                          Flexible(
                            child: Obx(() {
                              final rawBalance = walletController.walletBalance['totalBalance'];
                              double parsed = 0.0;
                              if (rawBalance != null) {
                                parsed = double.tryParse(rawBalance.toString()) ?? 0.0;
                              }
                              String formatBtc(double value) {
                                return value.toStringAsFixed(6);
                              }
                              final String displayBalance = formatBtc(parsed);
                              return FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "\$$displayBalance",
                                  style: CommonFontStyles.heading1.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),


                      SizedBox(
                        height: 190,
                        width: double.infinity,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              right: -25,
                              top: -20,
                              bottom: -20,
                              child: Obx(
                                    () =>
                                    VideoAssetPlayer(
                                      assetPath: ImageConst.minerVideo,
                                      width: 280,
                                      height: 230,
                                      fit: BoxFit.contain,
                                      isPlaying: socketService.remainingTime
                                          .value > 0,
                                    ),
                              ),

                            ),
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GradientBorderContainer(
                                    width: 120,
                                    height: 50,
                                    borderRadius: 16,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        Obx(() {
                                          final isMining = socketService.status.value.toUpperCase() == "MINING";
                                          final speed = isMining 
                                              ? (double.tryParse(socketService.currentSpeed.value) ?? homeController.effectiveMiningSpeed)
                                              : homeController.effectiveMiningSpeed;
                                          final speedText = speed >= 1000 
                                              ? (speed / 1000).toStringAsFixed(1) 
                                              : speed.toStringAsFixed(1);
                                          return Text(
                                            speedText,
                                            style: CommonFontStyles.heading2.copyWith(
                                              fontSize: 22,
                                              fontFamily: 'Poppins',
                                            ),
                                          );
                                        }),
                                        const SizedBox(width: 8),
                                        Obx(() {
                                          final isMining = socketService.status.value.toUpperCase() == "MINING";
                                          final speed = isMining 
                                              ? (double.tryParse(socketService.currentSpeed.value) ?? homeController.effectiveMiningSpeed)
                                              : homeController.effectiveMiningSpeed;
                                          return CommonText.small(
                                            speed >= 1000 ? "TH/s" : "GH/s",
                                            style: const TextStyle(color: Colors.grey),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  GradientBorderContainer(
                                    width: 120,
                                    height: 50,
                                    borderRadius: 16,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        Obx(() {
                                          final speedVal = double.tryParse(socketService.currentSpeed.value) ?? 0.0;
                                          final speedText = speedVal >= 1000 
                                              ? (speedVal / 1000).toStringAsFixed(1) 
                                              : speedVal.toStringAsFixed(1);
                                          return Text(
                                            speedText,
                                            style: CommonFontStyles.heading2.copyWith(
                                              fontSize: 22,
                                              fontFamily: 'Poppins',
                                            ),
                                          );
                                        }),
                                        const SizedBox(width: 8),
                                        const CommonText.small(
                                          "Count",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  GradientBorderContainer(
                                    width: 120,
                                    height: 50,
                                    borderRadius: 16,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        Obx(() {
                                          int activePlans = 1; // Free 10Gh is always active
                                          if (Get.isRegistered<StoreController>()) {
                                            if (Get.find<StoreController>().hasActivePlan) {
                                              activePlans += 1;
                                            }
                                          }
                                          if (homeController.isBoosting.value) {
                                            activePlans += 1;
                                          }
                                          return Text(
                                            activePlans.toString(),
                                            style: CommonFontStyles.heading2.copyWith(
                                              fontSize: 22,
                                              fontFamily: 'Poppins',
                                            ),
                                          );
                                        }),
                                        const SizedBox(width: 8),
                                        const CommonText.small(
                                          "Miner",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      const Center(child: AppNativeAd(factoryId: 'customNativeAdHome')),
                      const SizedBox(height: 12),

                      const CommonText.body(
                        "BTC Mined - TODAY",
                        style: TextStyle(
                            color: Colors.grey, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Obx(
                            () =>
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: CommonText.h1(
                                socketService.currentEarned.value,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                      ),
                      const SizedBox(height: 12),

                      Obx(() {
                        final remaining = socketService.remainingTime.value;
                        final isMining = socketService.status.value
                            .toUpperCase() == "MINING";
                        final isCompleted = socketService.status.value
                            .toUpperCase() == "COMPLETED";

                        int totalDuration = socketService.totalSessionDuration
                            .value;
                        if (totalDuration <= 0) {
                          totalDuration = 86400;
                        }

                        double displayProgress = 0.0;
                        if (isCompleted) {
                          displayProgress = 1.0;
                        } else if (isMining && remaining > 0) {
                          displayProgress = ((totalDuration - remaining) /
                              totalDuration).clamp(0.0, 1.0);
                        }

                        return Row(
                          children: List.generate(5, (index) {
                            // Calculate dynamic progress for each segment
                            final double segmentProgress = ((displayProgress *
                                5) - index).clamp(0.0, 1.0);

                            return Expanded(
                              child: Container(
                                height: 4,
                                margin: EdgeInsets.only(
                                  left: index == 0 ? 0 : 4,
                                  right: index == 4 ? 0 : 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: segmentProgress,
                                      heightFactor: 1.0,
                                      child: Container(
                                        color: CommonColor.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      }),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.bolt, color: CommonColor.orange,
                                  size: 18),
                              const SizedBox(width: 4),
                              Obx(() {
                                final statusData = socketService.miningStatus;
                                final dashPower = homeController.collectionPower
                                    .value;
                                final statusPower = statusData['collectionPower'] ??
                                    statusData['collection_power'] ??
                                    statusData['power'] ??
                                    statusData['session']?['collectionPower'] ??
                                    statusData['session']?['collection_power'] ??
                                    statusData['session']?['power'];
                                final power = statusPower != null
                                    ? (int.tryParse(statusPower.toString()) ??
                                    dashPower)
                                    : dashPower;
                                return CommonText.body(
                                  "$power%",
                                  style: const TextStyle(
                                    color: CommonColor.orange,
                                    fontWeight: FontWeight.normal,
                                  ),
                                );
                              }),
                              const SizedBox(width: 4),
                              const CommonText.body(
                                "Collection Power",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Obx(() {
                                final speed = homeController.effectiveMiningSpeed;
                                final speedText = speed >= 1000 
                                    ? (speed / 1000).toStringAsFixed(1) 
                                    : speed.toStringAsFixed(1);
                                return CommonText.body(
                                  "$speedText ",
                                  style: const TextStyle(fontWeight: FontWeight.normal),
                                );
                              }),
                              Obx(() {
                                final speed = homeController.effectiveMiningSpeed;
                                return CommonText.body(
                                  speed >= 1000 ? "TH/s" : "GH/s",
                                  style: const TextStyle(color: Colors.grey),
                                );
                              }),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  AppCustomDialog.show(
                                    context: context,
                                    title: "Mining Speed",
                                    message:
                                    "Estimated mining speed is dynamic and may increase or decrease based on network conditions, device performance, and server activity. This is normal app behavior.",
                                  );
                                },
                                child: const Icon(
                                  Icons.info_outline_rounded,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      Align(
                        alignment: Alignment.center,
                        child: Obx(() {
                          final isActive = socketService.remainingTime.value > 0 || socketService.status.value == "MINING";
                          final isLoading = socketService.isMiningLoading.value;
                          final formattedTime = _formatDuration(
                            socketService.remainingTime.value,
                          );

                          return GestureDetector(
                            onTap: isLoading
                                ? null
                                : () {
                              if (isActive) {
                                socketService.stopMiningSession();
                              } else {
                                AppCustomDialog.show(
                                  context: context,
                                  title: "Mining Speed",
                                  message: "Estimated mining speed is dynamic and may increase or decrease based on network conditions, device performance, and server activity. This is normal app behavior.",
                                  onPressed: () {
                                    socketService.startMiningSession();
                                  },
                                );
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 370,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: isActive
                                    ? CommonColor.greyCard
                                    : CommonColor.blue,
                                boxShadow: [
                                  BoxShadow(
                                    color: isActive
                                        ? Colors.black.withValues(alpha: 0.3)
                                        : CommonColor.blue.withValues(
                                        alpha: 0.5),
                                    blurRadius: isActive ? 10 : 20,
                                    spreadRadius: isActive ? 0 : 2,
                                  ),
                                ],
                              ),
                              child: GradientBorderContainer(
                                width: 370,
                                height: 60,
                                borderRadius: 16,
                                child: Center(
                                  child: isLoading
                                      ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                      : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isActive
                                            ? Icons.stop_circle_outlined
                                            : Icons.play_circle_filled_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 10),
                                      CommonText(
                                        isActive
                                            ? formattedTime
                                            : "START MINING SESSION",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.normal,
                                          letterSpacing: 1.2,
                                          fontFamily: CommonFontStyles.fontFamily,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 16),

                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 370,
                          decoration: BoxDecoration(
                            color: CommonColor.glassWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1.0,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              Center(
                                child: SvgPicture.asset(
                                  ImageConst.playButton,
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CommonText.body(
                                      "5X mining Speed-up",
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    CommonText.small(
                                      "Watch ads & earn 5 min extra power",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10,
                                        //
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Obx(() {
                                final isBoosting = homeController.isBoosting
                                    .value;
                                final secs = homeController
                                    .boostRemainingSeconds.value;
                                final mm = (secs ~/ 60).toString().padLeft(
                                    2, '0');
                                final ss = (secs % 60).toString().padLeft(
                                    2, '0');
                                final timerText = secs > 0
                                    ? "$mm:$ss"
                                    : "Boost";
                                return SizedBox(
                                  width: 90,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: isBoosting
                                        ? null
                                        : () => homeController.triggerBoost(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isBoosting
                                          ? Colors.grey[700]
                                          : CommonColor.blue,
                                      disabledBackgroundColor: Colors.grey[800],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding: EdgeInsets.zero,
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      timerText,
                                      style: TextStyle(
                                        color: isBoosting
                                            ? Colors.grey[400]
                                            : Colors.white,
                                        fontWeight: FontWeight.normal,
                                        fontSize: isBoosting ? 12 : 14,
                                      ),
                                    ),
                                  ),
                                );
                              }),

                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Obx(() {
                        final authController = Get.find<AuthController>();
                        final isSuperAdmin = authController.userRole.value
                            .toUpperCase() == 'SUPER_ADMIN';
                        if (!isSuperAdmin) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: () =>
                                    Get
                                        .to(() => const AdminMiningConfigScreen()),
                                child: GradientBorderContainer(
                                  width: 370,
                                  height: 60,
                                  borderRadius: 16,
                                  backgroundColor: Colors.black.withValues(
                                      alpha: 0.8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.admin_panel_settings,
                                          color: Colors.amber, size: 24),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            CommonText.body(
                                              "Admin Panel",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.white),
                                            ),
                                            CommonText.small(
                                              "admin@cryptomining.com",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.arrow_forward_ios,
                                          color: Colors.grey, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      }),

                      GestureDetector(
                        onTap: () {
                          Get.to(
                                () => const MaximizeProfitScreen(),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 300),
                          );
                        },
                        child: const Center(
                          child: CommonText.body(
                            "How to maximize profit?",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

// Widget _buildPlaceholderView(String title) {
//   return Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(
//           Icons.dashboard_outlined,
//           size: 64,
//           color: Colors.white.withValues(alpha: 0.3),
//         ),
//         const SizedBox(height: 16),
//         CommonText.h2(title),
//         const SizedBox(height: 2),
//         CommonText.body(
//           "Content will load here dynamically.",
//           style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
//         ),
//       ],
//     ),
//   );
// }
}

class VideoAssetPlayer extends StatefulWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool isPlaying;

  const VideoAssetPlayer({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    required this.isPlaying,
  });

  @override
  State<VideoAssetPlayer> createState() => _VideoAssetPlayerState();
}

class _VideoAssetPlayerState extends State<VideoAssetPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..initialize()
          .then((_) {
        if (mounted) {
          _controller.setLooping(true);
          setState(() {
            _isInitialized = true;
          });
          _updatePlaybackState();
        }
      })
          .catchError((error) {
        debugPrint("Error initializing video player: $error");
      });
  }

  void _updatePlaybackState() {
    if (_isInitialized) {
      if (widget.isPlaying) {
        _controller.seekTo(Duration.zero).then((_) {
          if (widget.isPlaying && mounted) {
            _controller.play();
            _controller.setVolume(0.0);
          }
        });
      } else {
        _controller.pause();
        _controller.setVolume(0.0);
      }
    }
  }

  @override
  void didUpdateWidget(covariant VideoAssetPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      _updatePlaybackState();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || !widget.isPlaying) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Transform.scale(
          scale: 0.72,
          alignment: const Alignment(0.3, 0.0),
          child: Image.asset(ImageConst.minerMachineImage, fit: widget.fit),
        ),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: FittedBox(
        fit: widget.fit,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
