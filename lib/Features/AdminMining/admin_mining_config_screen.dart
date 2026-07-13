import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_mining_config_controller.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_text.dart';
import '../../Utility/blue_button.dart';
import '../../Utility/black_card.dart';
import '../../Utility/custom_appbar.dart';

class AdminMiningConfigScreen extends StatelessWidget {
  const AdminMiningConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminMiningConfigController());

    return Scaffold(
      backgroundColor: CommonColor.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(title: "Admin Mining Config"),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: CommonColor.blue),
                  );
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CommonText.h3(
                        "Configure Mining Parameters",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.normal),
                      ),
                      const SizedBox(height: 16),

                      // Form Container
                      _buildInputField(
                        label: "Base Mining Speed (GH/s)",
                        controller: controller.baseMiningSpeedController,
                        keyboardType: TextInputType.number,
                      ),
                      _buildInputField(
                        label: "Mining Duration (Hours)",
                        controller: controller.miningDurationHoursController,
                        keyboardType: TextInputType.number,
                      ),
                      _buildInputField(
                        label: "Base Reward Per Hour (Decimal String)",
                        controller: controller.baseRewardPerHourController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                      _buildInputField(
                        label: "Ad Speed Bonus (GH/s)",
                        controller: controller.adSpeedBonusController,
                        keyboardType: TextInputType.number,
                      ),
                      _buildInputField(
                        label: "Ad Bonus Duration (Minutes)",
                        controller: controller.adBonusDurationMinutesController,
                        keyboardType: TextInputType.number,
                      ),
                      _buildInputField(
                        label: "Ad GPU Count",
                        controller: controller.adGpuCountController,
                        keyboardType: TextInputType.number,
                      ),
                      _buildInputField(
                        label: "Ad Miner Count",
                        controller: controller.adMinerCountController,
                        keyboardType: TextInputType.number,
                      ),
                      _buildInputField(
                        label: "Base GPU Count",
                        controller: controller.baseGpuCountController,
                        keyboardType: TextInputType.number,
                      ),
                      _buildInputField(
                        label: "Base Miner Count",
                        controller: controller.baseMinerCountController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        final isSaving = controller.isSaving.value;
                        return BlueButton(
                          text: isSaving ? "Saving..." : "Save Configuration",
                          width: double.infinity,
                          height: 48,
                          onPressed:
                              isSaving ? () {} : () => controller.saveConfig(),
                        );
                      }),

                      const SizedBox(height: 30),

                      // User Mining Sessions Header
                      const CommonText.h3(
                        "Recent User Mining Sessions",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.normal),
                      ),
                      const SizedBox(height: 12),

                      // Sessions List/Table
                      Obx(() {
                        if (controller.sessionsLoading.value) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: CircularProgressIndicator(
                                  color: CommonColor.blue),
                            ),
                          );
                        }

                        if (controller.sessionsList.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: CommonText.body(
                                "No active or past sessions found.",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.sessionsList.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final session = controller.sessionsList[index];
                            final userId =
                                session.userId.isEmpty ? 'N/A' : session.userId;
                            final status = session.status;
                            final speed = session.miningSpeed;
                            final startTimeRaw = session.startTime;
                            final duration = session.durationHours.toString();

                            String startTime = 'N/A';
                            if (startTimeRaw.isNotEmpty) {
                              try {
                                final parsedTime =
                                    DateTime.parse(startTimeRaw).toLocal();
                                startTime =
                                    "${parsedTime.day}/${parsedTime.month} ${parsedTime.hour.toString().padLeft(2, '0')}:${parsedTime.minute.toString().padLeft(2, '0')}";
                              } catch (_) {}
                            }

                            return GradientBorderContainer(
                              width: double.infinity,
                              borderRadius: 12,
                              backgroundColor:
                                  Colors.black.withValues(alpha: 0.4),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "User: $userId",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color:
                                              status.toUpperCase() == "MINING"
                                                  ? Colors.green
                                                      .withValues(alpha: 0.2)
                                                  : Colors.grey
                                                      .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color:
                                                status.toUpperCase() == "MINING"
                                                    ? Colors.green
                                                    : Colors.grey,
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            color:
                                                status.toUpperCase() == "MINING"
                                                    ? Colors.green
                                                    : Colors.grey,
                                            fontSize: 10,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CommonText.small("Started At",
                                              style: const TextStyle(
                                                  color: Colors.grey)),
                                          const SizedBox(height: 2),
                                          Text(
                                            startTime,
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          CommonText.small("Speed / Duration",
                                              style: const TextStyle(
                                                  color: Colors.grey)),
                                          const SizedBox(height: 2),
                                          Text(
                                            "$speed GH/s (${duration}h)",
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText.body(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[900]?.withValues(alpha: 0.5),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[800]!, width: 0.8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: CommonColor.blue, width: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
