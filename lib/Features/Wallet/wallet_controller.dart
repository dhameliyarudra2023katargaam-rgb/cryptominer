import 'dart:developer';
import 'package:get/get.dart';
import '../../Repo/wallet_repo.dart';
import '../../Utility/app_snackbar.dart';

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
      }
    } catch (e) {
      log("Error fetching wallet balance: $e");
    } finally {
      isLoadingBalance.value = false;
    }
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
