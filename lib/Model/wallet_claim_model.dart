class WalletClaimResponse {
  final bool success;
  final String message;
  final WalletClaimData? data;

  WalletClaimResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory WalletClaimResponse.fromJson(Map<String, dynamic> json) {
    return WalletClaimResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? WalletClaimData.fromJson(json['data']) : null,
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

class WalletClaimData {
  final String? id;
  final String? userId;
  final num? totalBalance;
  final num? withdrawableBalance;
  final String? bonusBalance;
  final num? claimedAmountUSD;
  final num? newWithdrawableBalance;

  WalletClaimData({
    this.id,
    this.userId,
    this.totalBalance,
    this.withdrawableBalance,
    this.bonusBalance,
    this.claimedAmountUSD,
    this.newWithdrawableBalance,
  });

  factory WalletClaimData.fromJson(Map<String, dynamic> json) {
    return WalletClaimData(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      userId: json['userId']?.toString(),
      totalBalance: _parseNum(json['totalBalance']),
      withdrawableBalance: _parseNum(json['withdrawableBalance']),
      bonusBalance: json['bonusBalance']?.toString(),
      claimedAmountUSD: _parseNum(json['claimedAmountUSD']),
      newWithdrawableBalance: _parseNum(json['newWithdrawableBalance']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'totalBalance': totalBalance,
      'withdrawableBalance': withdrawableBalance,
      'bonusBalance': bonusBalance,
      'claimedAmountUSD': claimedAmountUSD,
      'newWithdrawableBalance': newWithdrawableBalance,
    };
  }
}

num? _parseNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  return num.tryParse(value.toString());
}

