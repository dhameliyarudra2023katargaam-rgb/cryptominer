class AdminMiningConfigResponse {
  final bool success;
  final String message;
  final AdminMiningConfig? data;

  AdminMiningConfigResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AdminMiningConfigResponse.fromJson(Map<String, dynamic> json) {
    return AdminMiningConfigResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? AdminMiningConfig.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class AdminMiningConfig {
  final num baseMiningSpeed;
  final num miningDurationHours;
  final String baseRewardPerHour;
  final num adSpeedBonus;
  final num adBonusDurationMinutes;
  final num adGpuCount;
  final num adMinerCount;
  final num baseGpuCount;
  final num baseMinerCount;

  AdminMiningConfig({
    required this.baseMiningSpeed,
    required this.miningDurationHours,
    required this.baseRewardPerHour,
    required this.adSpeedBonus,
    required this.adBonusDurationMinutes,
    required this.adGpuCount,
    required this.adMinerCount,
    required this.baseGpuCount,
    required this.baseMinerCount,
  });

  factory AdminMiningConfig.fromJson(Map<String, dynamic> json) {
    return AdminMiningConfig(
      baseMiningSpeed: json['baseMiningSpeed'] ?? 0,
      miningDurationHours: json['miningDurationHours'] ?? 0,
      baseRewardPerHour: json['baseRewardPerHour']?.toString() ?? '0',
      adSpeedBonus: json['adSpeedBonus'] ?? 0,
      adBonusDurationMinutes: json['adBonusDurationMinutes'] ?? 0,
      adGpuCount: json['adGpuCount'] ?? 0,
      adMinerCount: json['adMinerCount'] ?? 0,
      baseGpuCount: json['baseGpuCount'] ?? 0,
      baseMinerCount: json['baseMinerCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseMiningSpeed': baseMiningSpeed,
      'miningDurationHours': miningDurationHours,
      'baseRewardPerHour': baseRewardPerHour,
      'adSpeedBonus': adSpeedBonus,
      'adBonusDurationMinutes': adBonusDurationMinutes,
      'adGpuCount': adGpuCount,
      'adMinerCount': adMinerCount,
      'baseGpuCount': baseGpuCount,
      'baseMinerCount': baseMinerCount,
    };
  }
}

class AdminMiningSessionsResponse {
  final bool success;
  final String message;
  final List<AdminMiningSession> data;

  AdminMiningSessionsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AdminMiningSessionsResponse.fromJson(Map<String, dynamic> json) {
    var rawList = json['data'] ?? json['sessions'] ?? [];
    List<AdminMiningSession> parsedList = [];
    if (rawList is List) {
      parsedList = rawList.map((item) => AdminMiningSession.fromJson(item)).toList();
    }
    return AdminMiningSessionsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: parsedList,
    );
  }
}

class AdminMiningSession {
  final String id;
  final String userId;
  final String status;
  final String miningSpeed;
  final int durationHours;
  final String startTime;
  final String? endTime;

  AdminMiningSession({
    required this.id,
    required this.userId,
    required this.status,
    required this.miningSpeed,
    required this.durationHours,
    required this.startTime,
    this.endTime,
  });

  factory AdminMiningSession.fromJson(Map<String, dynamic> json) {
    return AdminMiningSession(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'IDLE',
      miningSpeed: json['miningSpeed']?.toString() ?? json['speed']?.toString() ?? '0.0',
      durationHours: json['durationHours'] is int 
          ? json['durationHours'] 
          : (int.tryParse(json['durationHours']?.toString() ?? '0') ?? 0),
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString(),
    );
  }
}
