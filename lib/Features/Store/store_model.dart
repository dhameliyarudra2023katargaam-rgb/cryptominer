// ─────────────────────────────────────────────────────────────────────────────
// GET /subscriptions/plans  →  List<SubscriptionPlan>
// ─────────────────────────────────────────────────────────────────────────────

class SubscriptionPlan {
  final String id;
  final String name;
  final String displayName;
  final double price;
  final double miningSpeed; // GH/s
  final double aprPercent;
  final double freeCpuPercent;
  final String? discountText;
  final bool isPopular;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.displayName,
    required this.price,
    required this.miningSpeed,
    required this.aprPercent,
    required this.freeCpuPercent,
    this.discountText,
    this.isPopular = false,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? json['name']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      miningSpeed: double.tryParse(json['miningSpeed']?.toString() ?? '0') ?? 0.0,
      aprPercent: double.tryParse(json['aprPercent']?.toString() ?? '0') ?? 0.0,
      freeCpuPercent: double.tryParse(json['freeCpuPercent']?.toString() ?? '0') ?? 0.0,
      discountText: json['discountText']?.toString(),
      isPopular: json['isPopular'] == true,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GET /subscriptions/current  →  CurrentSubscription?
// ─────────────────────────────────────────────────────────────────────────────

class CurrentSubscription {
  final String id;
  final String planName;
  final String planDisplayName;
  final double miningSpeed;
  final String status;
  final String startDate;
  final String endDate;

  CurrentSubscription({
    required this.id,
    required this.planName,
    required this.planDisplayName,
    required this.miningSpeed,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  factory CurrentSubscription.fromJson(Map<String, dynamic> json) {
    final plan = json['plan'] as Map<String, dynamic>?;
    return CurrentSubscription(
      id: json['_id']?.toString() ?? '',
      planName: plan?['name']?.toString() ?? json['planName']?.toString() ?? '',
      planDisplayName: plan?['displayName']?.toString() ??
          json['planDisplayName']?.toString() ??
          json['planName']?.toString() ??
          '',
      miningSpeed: double.tryParse(
              (plan?['miningSpeed'] ?? json['miningSpeed'])?.toString() ?? '0') ??
          0.0,
      status: json['status']?.toString() ?? 'ACTIVE',
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GET /subscriptions/history  →  List<SubscriptionHistory>
// ─────────────────────────────────────────────────────────────────────────────

class SubscriptionHistory {
  final String id;
  final String planName;
  final String planDisplayName;
  final double price;
  final String status;
  final String purchasedAt;
  final String paymentMethod;

  SubscriptionHistory({
    required this.id,
    required this.planName,
    required this.planDisplayName,
    required this.price,
    required this.status,
    required this.purchasedAt,
    required this.paymentMethod,
  });

  factory SubscriptionHistory.fromJson(Map<String, dynamic> json) {
    final plan = json['plan'] as Map<String, dynamic>?;
    return SubscriptionHistory(
      id: json['_id']?.toString() ?? '',
      planName: plan?['name']?.toString() ?? json['planName']?.toString() ?? '',
      planDisplayName: plan?['displayName']?.toString() ??
          json['planDisplayName']?.toString() ??
          '',
      price: double.tryParse(
              (plan?['price'] ?? json['price'])?.toString() ?? '0') ??
          0.0,
      status: json['status']?.toString() ?? '',
      purchasedAt: json['purchasedAt']?.toString() ??
          json['createdAt']?.toString() ??
          '',
      paymentMethod: json['paymentMethod']?.toString() ?? 'CRYPTO',
    );
  }
}
