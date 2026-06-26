import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Repo/wallet_repo.dart';

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
      Get.snackbar(
        "Invalid Amount",
        "Please enter a valid amount",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return false;
    }
    if (address.isEmpty) {
      Get.snackbar(
        "Required",
        "Please enter address details",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
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

        Get.snackbar(
          "Success",
          response['message'] ?? "Withdrawal request submitted successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        // Refresh balance and history
        fetchWalletBalance();
        fetchWithdrawalHistory();
        return true;
      } else {
        Get.snackbar(
          "Error",
          response?['message'] ?? "Failed to request withdrawal",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      log("Error requesting withdrawal: $e");
      Get.snackbar(
        "Error",
        "Something went wrong",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmittingWithdrawal.value = false;
    }
  }
}
