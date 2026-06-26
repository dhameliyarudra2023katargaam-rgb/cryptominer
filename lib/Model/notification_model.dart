class NotificationModel {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final String createdAt;
  final String? rewardAmount;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.rewardAmount,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawMessage = json['message']?.toString() ?? '';
    final rewardAmount = json['rewardAmount']?.toString();
    
    String formattedMessage = rawMessage.replaceAll(RegExp(r'[Yy]ou earned'), 'Reward');
    if (rewardAmount != null && rewardAmount.isNotEmpty) {
      formattedMessage = "Reward $rewardAmount BTC";
    }

    return NotificationModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: formattedMessage,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt']?.toString() ?? '',
      rewardAmount: rewardAmount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt,
      'rewardAmount': rewardAmount,
    };
  }
}

class NotificationListResponse {
  final bool success;
  final String message;
  final List<NotificationModel> data;

  NotificationListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List?;
    List<NotificationModel> notifications = dataList != null
        ? dataList.map((item) => NotificationModel.fromJson(item)).toList()
        : [];
    return NotificationListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: notifications,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class UnreadCountResponse {
  final bool success;
  final String message;
  final int unreadCount;

  UnreadCountResponse({
    required this.success,
    required this.message,
    required this.unreadCount,
  });

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      unreadCount: json['data']?['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': {
        'unreadCount': unreadCount,
      },
    };
  }
}

class NotificationActionResponse {
  final bool success;
  final String message;

  NotificationActionResponse({
    required this.success,
    required this.message,
  });

  factory NotificationActionResponse.fromJson(Map<String, dynamic> json) {
    return NotificationActionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}
