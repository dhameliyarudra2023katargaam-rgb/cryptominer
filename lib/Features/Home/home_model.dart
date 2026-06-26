class StartMiningResponse {
  final bool success;
  final String message;
  final StartMiningData? data;

  StartMiningResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory StartMiningResponse.fromJson(Map<String, dynamic> json) {
    return StartMiningResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? StartMiningData.fromJson(json['data']) : null,
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

class StartMiningData {
  final MiningSession? session;

  StartMiningData({this.session});

  factory StartMiningData.fromJson(Map<String, dynamic> json) {
    return StartMiningData(
      session: json['session'] != null ? MiningSession.fromJson(json['session']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session': session?.toJson(),
    };
  }
}

class MiningSession {
  final String sessionId;
  final String startTime;
  final String endTime;
  final String miningSpeed;
  final String rewardPerSecond;
  final String rewardSource;
  final int durationHours;

  MiningSession({
    required this.sessionId,
    required this.startTime,
    required this.endTime,
    required this.miningSpeed,
    required this.rewardPerSecond,
    required this.rewardSource,
    required this.durationHours,
  });

  factory MiningSession.fromJson(Map<String, dynamic> json) {
    return MiningSession(
      sessionId: json['sessionId'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      miningSpeed: json['miningSpeed']?.toString() ?? '0',
      rewardPerSecond: json['rewardPerSecond']?.toString() ?? '0.00000000',
      rewardSource: json['rewardSource'] ?? '',
      durationHours: json['durationHours'] ?? 24,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'startTime': startTime,
      'endTime': endTime,
      'miningSpeed': miningSpeed,
      'rewardPerSecond': rewardPerSecond,
      'rewardSource': rewardSource,
      'durationHours': durationHours,
    };
  }
}

class StopMiningResponse {
  final bool success;
  final String message;
  final StopMiningData? data;

  StopMiningResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory StopMiningResponse.fromJson(Map<String, dynamic> json) {
    return StopMiningResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? StopMiningData.fromJson(json['data']) : null,
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

class StopMiningData {
  final String rewardAmount;
  final String sessionId;

  StopMiningData({
    required this.rewardAmount,
    required this.sessionId,
  });

  factory StopMiningData.fromJson(Map<String, dynamic> json) {
    return StopMiningData(
      rewardAmount: json['rewardAmount']?.toString() ?? '0.00000000',
      sessionId: json['sessionId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rewardAmount': rewardAmount,
      'sessionId': sessionId,
    };
  }
}
