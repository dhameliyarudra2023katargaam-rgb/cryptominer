import 'dart:developer';
import 'package:get/get.dart';
import '../../Repo/wallet_repo.dart';
import '../../Utility/app_snackbar.dart';
import '../../Service/storage_service.dart';
import '../../Service/Ads/ad_service.dart';
import '../../Model/wallet_claim_model.dart';

class WalletController extends GetxController {
  final RxMap<String, dynamic> walletBalance = <String, dynamic>{}.obs;
  final RxList<dynamic> transactions = <dynamic>[].obs;
  final RxBool isLoadingBalance = false.obs;
  final RxBool isLoadingTransactions = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWalletBalance();
    fetchWalletTransactions();
    fetchWithdrawalHistory();
  }

  Future<void> fetchWalletBalance() async {
    try {
      isLoadingBalance.value = true;
      final response = await WalletRepo.getWalletBalance();
      if (response != null && response['success'] == true) {
        walletBalance.value = response['data'] ?? response;
        _updateWalletBalanceWithLocalOffsets();
      }
    } catch (e) {
      log("Error fetching wallet balance: $e");
    } finally {
      isLoadingBalance.value = false;
    }
  }

  Future<void> claimBonusReward() async {
    if (isLoadingBalance.value) return;
    
    // 1. Show rewarded ad
    try {
      isLoadingBalance.value = true;
      final bool adWatched = await AdService.instance.showAd(
        adType: 'rewarded',
        retryOnFailure: false,
      );
      
      if (!adWatched) {
        AppSnackbar.error("You must watch the full ad to claim your rewards.", title: "Ad Failed");
        return;
      }
      
      // 2. Call the claim API
      final WalletClaimResponse? response = await WalletRepo.claimWallet();
      
      if (response != null && response.success == true) {
        // Update local state immediately for instant UI response
        final responseData = response.data;
        if (responseData != null) {
          final String withdrawableStr = _toPlainDecimal((responseData.newWithdrawableBalance ?? responseData.withdrawableBalance ?? 0.0).toString());
          final String claimedStr = _toPlainDecimal((responseData.claimedAmountUSD ?? 0.0).toString());
          walletBalance.value = {
            'totalBalance': _divideByTen(withdrawableStr),
            'withdrawableBalance': _divideByTen(withdrawableStr),
            'bonusBalance': _divideByTen(claimedStr),
          };
          _updateWalletBalanceWithLocalOffsets();
        }

        // // 3. Refresh balance and transactions from server
        // await fetchWalletBalance();

        await fetchWalletTransactions();
        
        AppSnackbar.success(
          response.message,
          title: "Reward Claimed",
        );
      } else {
        AppSnackbar.error(
          response?.message ?? "Failed to claim reward",
          title: "Claim Failed",
        );
      }
    } catch (e) {
      log("Error claiming reward: $e");
      AppSnackbar.error("Failed to claim reward: $e");
    } finally {
      isLoadingBalance.value = false;
    }
  }

  void _updateWalletBalanceWithLocalOffsets() {
    if (walletBalance.isEmpty) return;
    
    // Read local offsets
    double localClaimedUsd = SharedPrefHelper.getDouble("local_claimed_usd") ?? 0.0;
    double localClaimedBtc = SharedPrefHelper.getDouble("local_claimed_btc") ?? 0.0;
    
    // Update map values
    final Map<String, dynamic> updatedMap = Map<String, dynamic>.from(walletBalance);
    
    final String rawTotal = _toPlainDecimal((updatedMap['totalBalance'] ?? "0.0").toString());
    final String rawWithdrawable = _toPlainDecimal((updatedMap['withdrawableBalance'] ?? "0.0").toString());
    final String rawBonus = _toPlainDecimal((updatedMap['bonusBalance'] ?? "0.0").toString());
    
    // Total & Withdrawable double computation (retaining offset logic)
    double serverTotal = double.tryParse(rawTotal) ?? 0.0;
    double finalTotal = serverTotal * 10.0 + localClaimedUsd;
    
    double serverWithdrawable = double.tryParse(rawWithdrawable) ?? 0.0;
    double finalWithdrawable = serverWithdrawable * 10.0 + localClaimedUsd;
    
    if (finalTotal < finalWithdrawable) {
      finalTotal = finalWithdrawable;
    }
    
    updatedMap['totalBalance'] = finalTotal.toString();
    updatedMap['withdrawableBalance'] = finalWithdrawable.toString();
    
    // Bonus exact multiplication
    if (localClaimedBtc == 0.0) {
      String multiplied = _multiplyByTen(rawBonus);
      if (multiplied.contains('.')) {
        while (multiplied.endsWith('0')) {
          multiplied = multiplied.substring(0, multiplied.length - 1);
        }
        if (multiplied.endsWith('.')) {
          multiplied = multiplied.substring(0, multiplied.length - 1);
        }
      }
      updatedMap['bonusBalance'] = multiplied;
    } else {
      double serverBonus = double.tryParse(rawBonus) ?? 0.0;
      double finalBonus = (serverBonus * 10.0) - localClaimedBtc;
      updatedMap['bonusBalance'] = finalBonus > 0 ? finalBonus.toString() : "0.00000000";
    }
    
    walletBalance.value = updatedMap;
  }

  String _divideByTen(String value) {
    value = value.trim();
    if (value == "0" || value == "0.0" || double.tryParse(value) == 0.0) {
      return "0.00000000";
    }
    if (!value.contains('.')) {
      if (value.length > 1) {
        return "${value.substring(0, value.length - 1)}.${value[value.length - 1]}";
      }
      return "0.$value";
    }
    if (value.startsWith("0.")) {
      return "0.0${value.substring(2)}";
    }
    int dotIndex = value.indexOf('.');
    String beforeDot = value.substring(0, dotIndex);
    String afterDot = value.substring(dotIndex + 1);
    if (beforeDot.length > 1) {
      return "${beforeDot.substring(0, beforeDot.length - 1)}.${beforeDot[beforeDot.length - 1]}$afterDot";
    }
    return "0.$beforeDot$afterDot";
  }

  String _multiplyByTen(String value) {
    value = value.trim();
    if (value == "0" || value == "0.0" || double.tryParse(value) == 0.0) {
      return "0.00000000";
    }
    if (!value.contains('.')) {
      return "${value}0";
    }
    if (value.startsWith("0.")) {
      String rest = value.substring(2);
      if (rest.startsWith("0")) {
        return "0.${rest.substring(1)}";
      } else {
        if (rest.length > 1) {
          return "${rest[0]}.${rest.substring(1)}";
        } else {
          return rest;
        }
      }
    }
    int dotIndex = value.indexOf('.');
    String beforeDot = value.substring(0, dotIndex);
    String afterDot = value.substring(dotIndex + 1);
    return "$beforeDot${afterDot[0]}.${afterDot.substring(1)}";
  }

  String _toPlainDecimal(String value) {
    value = value.trim();
    if (value.contains('e') || value.contains('E')) {
      double parsed = double.tryParse(value) ?? 0.0;
      String s = parsed.toStringAsFixed(20);
      while (s.endsWith('0')) {
        s = s.substring(0, s.length - 1);
      }
      if (s.endsWith('.')) {
        s = s.substring(0, s.length - 1);
      }
      return s;
    }
    return value;
  }

  Future<void> fetchWalletTransactions() async {
    try {
      isLoadingTransactions.value = true;
      final response = await WalletRepo.getWalletTransactions();
      if (response != null && response['success'] == true) {
        final listData = response['data'];
        if (listData is List) {
          transactions.value = listData;
        } else if (response['transactions'] is List) {
          transactions.value = response['transactions'];
        }
      }
    } catch (e) {
      log("Error fetching wallet transactions: $e");
    } finally {
      isLoadingTransactions.value = false;
    }
  }

  final RxList<dynamic> withdrawalHistory = <dynamic>[].obs;
  final RxBool isLoadingWithdrawalHistory = false.obs;
  final RxBool isSubmittingWithdrawal = false.obs;
  final RxString lastWithdrawalId = "".obs;

  Future<void> fetchWithdrawalHistory() async {
    try {
      isLoadingWithdrawalHistory.value = true;
      final response = await WalletRepo.getWithdrawalHistory();
      if (response != null && response['success'] == true) {
        final listData = response['data'];
        if (listData is List) {
          withdrawalHistory.value = listData;
        } else if (response['withdrawals'] is List) {
          withdrawalHistory.value = response['withdrawals'];
        }
      }
    } catch (e) {
      log("Error fetching withdrawal history: $e");
    } finally {
      isLoadingWithdrawalHistory.value = false;
    }
  }

  Future<bool> submitWithdrawal(double amount, String address, String type) async {
    if (amount <= 0) {
      AppSnackbar.error("Please enter a valid amount", title: "Invalid Amount");
      return false;
    }
    if (address.isEmpty) {
      AppSnackbar.error("Please enter address details", title: "Required");
      return false;
    }

    try {
      isSubmittingWithdrawal.value = true;
      
      // Map UI values to backend enum values ('lightning_address' or 'invoice')
      String mappedType = "lightning_address";
      if (type.toLowerCase().contains("invoice")) {
        mappedType = "invoice";
      } else if (type.toLowerCase().contains("light")) {
        mappedType = "lightning_address";
      } else {
        mappedType = type.toLowerCase();
      }

      final Map<String, dynamic> body = {
        "amount": amount.toString(),
        "address": address,
        "walletAddress": address,
        "type": mappedType,
        "withdrawalType": mappedType,
        "withdrawal_type": mappedType,
        "network": mappedType,
        "method": mappedType,
        "paymentMethod": mappedType,
        "withdrawalMethod": mappedType,
        "withdrawal_method": mappedType,
        "payment_method": mappedType,
      };
      
      final response = await WalletRepo.requestWithdrawal(body);
      if (response != null && response['success'] == true) {
        // Extract and store last withdrawal ID
        final data = response['data'];
        if (data != null && data is Map) {
          lastWithdrawalId.value = data['_id']?.toString() ?? data['id']?.toString() ?? "";
        } else {
          lastWithdrawalId.value = "";
        }

        AppSnackbar.success(
          response['message'] ?? "Withdrawal request submitted successfully",
        );
        // Refresh balance and history
        fetchWalletBalance();
        fetchWithdrawalHistory();
        return true;
      } else {
        AppSnackbar.error(
          response?['message'] ?? "Failed to request withdrawal",
        );
        return false;
      }
    } catch (e) {
      log("Error requesting withdrawal: $e");
      AppSnackbar.error("Something went wrong");
      return false;
    } finally {
      isSubmittingWithdrawal.value = false;
    }
  }
}
