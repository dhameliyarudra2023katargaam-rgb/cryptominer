import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Model/notification_model.dart';
import '../../Service/notification_service.dart';
import '../../Utility/common_color.dart';
import '../../Utility/common_text.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = Get.find<NotificationService>();

  @override
  void initState() {
    super.initState();
    _notificationService.fetchNotifications();
    _notificationService.fetchUnreadCount();
  }

  String _timeAgo(String dateTimeStr) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeStr).toLocal();
      final Duration difference = DateTime.now().difference(dateTime);

      if (difference.inDays > 7) {
        return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
      } else if (difference.inDays >= 1) {
        return "${difference.inDays}d ago";
      } else if (difference.inHours >= 1) {
        return "${difference.inHours}h ago";
      } else if (difference.inMinutes >= 1) {
        return "${difference.inMinutes}m ago";
      } else {
        return "Just now";
      }
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColor.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText.h2(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Obx(() {
            if (_notificationService.unreadCount.value > 0) {
              return TextButton.icon(
                onPressed: () => _notificationService.markAllAsRead(),
                icon: const Icon(Icons.done_all, color: CommonColor.blue, size: 18),
                label: const Text(
                  "Read All",
                  style: TextStyle(color: CommonColor.blue, fontWeight: FontWeight.bold),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _notificationService.fetchNotifications();
          await _notificationService.fetchUnreadCount();
        },
        color: CommonColor.blue,
        backgroundColor: CommonColor.greyCard,
        child: Obx(() {
          if (_notificationService.isLoading.value && _notificationService.notifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: CommonColor.blue),
            );
          }

          if (_notificationService.notifications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _notificationService.notifications.length,
            itemBuilder: (context, index) {
              final NotificationModel notification = _notificationService.notifications[index];
              final id = notification.id;
              final title = notification.title;
              final message = notification.message;
              final isRead = notification.isRead;
              final createdAt = notification.createdAt;

              return Dismissible(
                key: Key(id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: CommonColor.red.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                ),
                onDismissed: (direction) {
                  _notificationService.deleteNotification(id);
                },
                child: GestureDetector(
                  onTap: () {
                    if (!isRead) {
                      _notificationService.markAsRead(id);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isRead ? CommonColor.greyCard : CommonColor.greyCard.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isRead ? Colors.transparent : CommonColor.blue.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isRead
                                ? Colors.white.withValues(alpha: 0.05)
                                : CommonColor.blue.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isRead ? Icons.notifications_none : Icons.notifications_active,
                            color: isRead ? Colors.grey : CommonColor.blue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (createdAt.isNotEmpty)
                                    Text(
                                      _timeAgo(createdAt),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                message,
                                style: TextStyle(
                                  color: isRead ? Colors.grey[400] : Colors.white,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: CommonColor.greyCard,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Icon(
                Icons.notifications_none_outlined,
                size: 64,
                color: Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 24),
            const CommonText.h2(
              "No Notifications",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CommonText.body(
              "You will see updates and alerts here.",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
