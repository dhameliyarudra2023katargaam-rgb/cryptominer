// ─────────────────────────────────────────────────────────────────────────────
// GET /referrals/info  →  ReferralInfo
// ─────────────────────────────────────────────────────────────────────────────

class ReferralInfo {
  final String referralCode;
  final String referralLink;
  final int totalReferrals;
  final String totalRewardsEarned;
  final String pendingRewards;

  ReferralInfo({
    required this.referralCode,
    required this.referralLink,
    required this.totalReferrals,
    required this.totalRewardsEarned,
    required this.pendingRewards,
  });

  factory ReferralInfo.fromJson(Map<String, dynamic> json) {
    return ReferralInfo(
      referralCode: json['referralCode']?.toString() ?? '',
      referralLink: json['referralLink']?.toString() ?? '',
      totalReferrals: int.tryParse(json['totalReferrals']?.toString() ?? '0') ?? 0,
      totalRewardsEarned: json['totalRewardsEarned']?.toString() ?? '0.00000000',
      pendingRewards: json['pendingRewards']?.toString() ?? '0.00000000',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GET /referrals/users  →  List<ReferredUser>
// ─────────────────────────────────────────────────────────────────────────────

class ReferredUser {
  final String id;
  final String name;
  final String email;
  final String joinedAt;
  final bool isMiningActive;
  final String miningDuration; // e.g. "05hr,26min"

  ReferredUser({
    required this.id,
    required this.name,
    required this.email,
    required this.joinedAt,
    required this.isMiningActive,
    required this.miningDuration,
  });

  factory ReferredUser.fromJson(Map<String, dynamic> json) {
    return ReferredUser(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      email: json['email']?.toString() ?? '',
      joinedAt: json['joinedAt']?.toString() ?? json['createdAt']?.toString() ?? '',
      isMiningActive: json['isMiningActive'] == true ||
          json['miningStatus']?.toString().toLowerCase() == 'mining',
      miningDuration: json['miningDuration']?.toString() ?? '00hr,00min',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GET /referrals/rewards  →  ReferralRewards
// ─────────────────────────────────────────────────────────────────────────────

class ReferralReward {
  final String id;
  final String fromUserName;
  final String amount;
  final String type;  // e.g. "Mining Bonus", "Sign-up Bonus"
  final String earnedAt;

  ReferralReward({
    required this.id,
    required this.fromUserName,
    required this.amount,
    required this.type,
    required this.earnedAt,
  });

  factory ReferralReward.fromJson(Map<String, dynamic> json) {
    return ReferralReward(
      id: json['_id']?.toString() ?? '',
      fromUserName: json['fromUserName']?.toString() ??
          json['fromUser']?['name']?.toString() ??
          'Unknown',
      amount: json['amount']?.toString() ?? '0.00000000',
      type: json['type']?.toString() ?? 'Referral Reward',
      earnedAt: json['earnedAt']?.toString() ??
          json['createdAt']?.toString() ??
          '',
    );
  }
}
