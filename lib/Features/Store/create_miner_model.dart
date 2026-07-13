// ─────────────────────────────────────────────────────────────────────────────
// Create Miner - Model
// As shown in image: Select CPU (10/20/30 Th/s), Estimate Profit, Rental Duration
// API: use same /subscriptions/plans & /subscriptions/purchase
// ─────────────────────────────────────────────────────────────────────────────

/// CPU Speed option as shown in image (10 Th/s, 20 Th/s, 30 Th/s)
class CpuSpeedOption {
  final String label;     // "10 Th/s"
  final double speedThs;  // 10.0

  const CpuSpeedOption({
    required this.label,
    required this.speedThs,
  });
}

/// Rental Duration plan - 1 Month, 3 Month, 6 Month as shown in image
class CreateMinerPlan {
  final String id;
  final String displayName;
  final double price;
  final int durationMonths;   // 1, 3, 6
  final double miningSpeedThs; // Th/s
  final double estimateProfitPercent; // e.g. 30.1
  final bool isPopular;

  const CreateMinerPlan({
    required this.id,
    required this.displayName,
    required this.price,
    required this.durationMonths,
    required this.miningSpeedThs,
    required this.estimateProfitPercent,
    this.isPopular = false,
  });

  factory CreateMinerPlan.fromJson(Map<String, dynamic> json) {
    // Duration: months parse from plan name or durationDays
    int months = 1;
    final durationDays =
        int.tryParse(json['durationDays']?.toString() ?? '30') ?? 30;
    if (durationDays <= 31) {
      months = 1;
    } else if (durationDays <= 92) {
      months = 3;
    } else {
      months = 6;
    }

    return CreateMinerPlan(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      displayName:
          json['displayName']?.toString() ?? json['name']?.toString() ?? '',
      price:
          double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      durationMonths: months,
      miningSpeedThs:
          double.tryParse(json['miningSpeed']?.toString() ?? '0') ?? 0.0,
      estimateProfitPercent:
          double.tryParse(json['aprPercent']?.toString() ?? '0') ?? 0.0,
      isPopular: json['isPopular'] == true,
    );
  }

  /// Duration label - "1 Month", "3 Month", "6 Month"
  String get durationLabel =>
      durationMonths == 1 ? '1 Month' : '$durationMonths Month';

  /// Subscribe button label - "Subscribe ₹2050 / 3 Mon"
  String get subscribeLabel =>
      'Subscribe ₹${price.toStringAsFixed(0)} / $durationMonths Mon';

  /// Card top label - "₹720 / 1 Month"
  String get priceLabel => '₹${price.toStringAsFixed(0)} / $durationLabel';
}

/// Response after subscribe / purchase
class CreateMinerPurchaseResult {
  final bool success;
  final String message;

  const CreateMinerPurchaseResult({
    required this.success,
    required this.message,
  });
}
