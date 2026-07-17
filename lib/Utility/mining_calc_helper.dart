class MiningCalcHelper {
  // Base rates for 1 GH/s based on the new table
  // 10 GH/s gives $0.0333 per 30 days => 1 GH/s = 0.00333 per month
  static const double baseMonthlyUsdPerGh = 0.003333333333333333;
  // 10 GH/s gives 0.00000000000010 BTC per second => 1 GH/s = 0.00000000000001 BTC per second
  static const double baseBtcPerSecondPerGh = 0.000000000000001;

  /// Returns the estimated $/Month based on mining speed in GH/s
  static double getMonthlyUsd(double speedGh) {
    return speedGh * baseMonthlyUsdPerGh;
  }

  /// Returns the estimated BTC/Second based on mining speed in GH/s
  static double getBtcPerSecond(double speedGh) {
    return speedGh * baseBtcPerSecondPerGh;
  }
}
