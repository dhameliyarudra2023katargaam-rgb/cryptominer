import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../Api/api_const.dart';
import 'storage_service.dart';
import '../Auth/auth_controller.dart';
import '../Repo/home_screen_mining_repo.dart';
import '../Features/Home/home_model.dart';
import 'notification_service.dart';

class SocketService extends GetxService with WidgetsBindingObserver {
  io.Socket? _socket;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  // Observables for real-time mining state
  final RxString currentMiningBalance = "0.5555555555".obs;
  final RxString currentEarned = "0.000000000000000000".obs;
  final RxString currentSpeed = "0.0".obs;
  final RxInt remainingTime = 0.obs;
  final RxString status = "IDLE".obs;
  final RxInt totalSessionDuration = 86400.obs;
  final RxBool isConnected = false.obs;


  // Real-time logs list
  final RxList<String> logs = <String>[].obs;

  void addLog(String message) {
    final String timestamp = DateTime.now().toLocal().toString().split(' ')[1].substring(0, 8);
    logs.insert(0, "[$timestamp] $message");
    if (logs.length > 50) {
      logs.removeLast();
    }
  }

  /// Connect to the Socket.IO server
  void connectSocket() {
    if (_socket != null && _socket!.connected) {
      dev.log("🔌 SocketService: Already connected, skipping connection.");
      return;
    }

    // Disconnect any existing socket first
    disconnectSocket();

    final String? token = SharedPrefHelper.getString("token");
    dev.log("Token ::::::::::::::::::::::::: ${token.toString()}");

    if (token == null || token.isEmpty) {
      dev.log("⚠️ SocketService: Cannot connect because JWT Token is null or empty.");
      return;
    }

    final String url = ApiConst.socketUrl;
    final String tokenSnippet = token.length > 10 ? token.substring(0, 10) : token;
    dev.log("🔌 SocketService: Connecting to $url with token: $tokenSnippet...");
    _socket = io.io(url,
      io.OptionBuilder()
        .setTransports(['websocket'])
        .setAuth({
          'token': token,
          'authorization': 'Bearer $token',
          'Authorization': 'Bearer $token',
        })
        .setQuery({
          'token': token,
          'authorization': 'Bearer $token',
          'Authorization': 'Bearer $token',
        })
        .setExtraHeaders({
          'authorization': 'Bearer $token',
          'Authorization': 'Bearer $token',
        })
        .enableForceNew()
        .disableAutoConnect()
        .build()
    );
    _socket?.onConnect((_) {
      isConnected.value = true;
      dev.log("🟢 SocketService: Connected to Socket.IO server successfully.");
      addLog("🟢 Socket connected successfully!");
      // Subscribe to mining updates
      subscribeMining();
      // Request initial status immediately on connection
      requestMiningStatus();
    });
    _socket?.onDisconnect((reason) {
      isConnected.value = false;
      dev.log("🔴 SocketService: Disconnected from Socket.IO server: $reason");
      addLog("🔴 Socket disconnected: $reason");
    });

    _socket?.onConnectError((error) {
      dev.log("❌ SocketService: Connection Error: $error");
      addLog("❌ Connection Error: $error");
    });

    _socket?.onError((error) {
      dev.log("❌ SocketService: Socket Error: $error");
      addLog("❌ Socket Error: $error");
    });

    // Helper to process mining data
    void handleMiningData(dynamic data) {
      if (isMiningLoading.value) {
        dev.log("📡 SocketService: Received mining data ignored because start/stop API is in progress.");
        return;
      }
      dev.log("📡 SocketService: Received mining data: $data");
      addLog("📡 Received mining data: $data");
      _localMiningTimer?.cancel();

      if (data != null && data is Map) {
        miningStatus.addAll(Map<String, dynamic>.from(data));
        final serverMiningBalance = data['currentMiningBalance'] ?? data['miningBalance'];
        final serverEarned = data['currentEarned'] ?? data['earned'];

        double baseBal = 0.0;
        if (serverMiningBalance != null) {
          baseBal = double.tryParse(serverMiningBalance.toString()) ?? 0.0;
        }

        double earnedBal = 0.0;
        if (serverEarned != null) {
          earnedBal = double.tryParse(serverEarned.toString()) ?? 0.0;
        }

        double totalBal = baseBal + earnedBal;
        currentMiningBalance.value = totalBal.toStringAsFixed(18);

        if (serverEarned != null) {
          if (serverEarned is num) {
            currentEarned.value = serverEarned.toStringAsFixed(18);
          } else {
            currentEarned.value = serverEarned.toString();
          }
        }

        currentSpeed.value = data['currentSpeed']?.toString() ?? "0.0";

        final rawRemaining = data['remainingTime'];
        if (rawRemaining is int) {
          remainingTime.value = rawRemaining;
        } else if (rawRemaining is double) {
          remainingTime.value = rawRemaining.toInt();
        } else if (rawRemaining is String) {
          remainingTime.value = int.tryParse(rawRemaining) ?? 0;
        } else {
          remainingTime.value = 0;
        }
        status.value = data['status']?.toString() ?? "IDLE";
      }
    }

    // Listen to miningTick event (as per API Doc)
    // _socket?.on('miningTick', handleMiningData);
    _socket?.on('mining:status', handleMiningData);

    // Optional: Log all incoming events for troubleshooting
    _socket?.onAny((event, data) {
      dev.log("📩 SocketService Any Event: '$event' | Data: $data");
    });

    _socket?.connect();
  }

  /// Emit requestMiningStatus event (Optional - triggers instant miningTick response)
  void requestMiningStatus() {
    if (_socket != null && _socket!.connected) {
      dev.log("📤 SocketService: Emitting 'requestMiningStatus'...");
      _socket!.emit('requestMiningStatus');
      addLog("📤 Emitted requestMiningStatus");
    } else {
      dev.log("⚠️ SocketService: Cannot emit. Socket not connected.");
    }
  }

  /// Emit mining:subscribe event to start receiving live updates
  void subscribeMining() {
    if (_socket != null && _socket!.connected) {
      dev.log("📤 SocketService: Emitting 'mining:subscribe'...");
      _socket!.emit('mining:subscribe');
      addLog("📤 Emitted mining:subscribe");
    } else {
      dev.log("⚠️ SocketService: Cannot emit mining:subscribe. Socket not connected.");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    dev.log("📱 SocketService: AppLifecycleState changed to: $state");
    if (state == AppLifecycleState.resumed) {
      final String? token = SharedPrefHelper.getString("token");
      if (token != null && token.isNotEmpty && status.value == "MINING") {
        dev.log("📱 SocketService: App resumed while mining. Reconnecting/resubscribing socket...");
        fetchMiningStatus();
        if (_socket != null && _socket!.connected) {
          subscribeMining();
        } else {
          connectSocket();
        }
      }
    }
  }

  /// Disconnect Socket
  void disconnectSocket() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      isConnected.value = false;
      dev.log("🔌 SocketService: Socket disconnected and cleaned up.");
    }
    _localMiningTimer?.cancel();
  }

  Timer? _localMiningTimer;

  void startLocalMiningTimer(int durationSeconds, {bool resetBalance = false}) {
    _localMiningTimer?.cancel();
    remainingTime.value = durationSeconds;
    status.value = "MINING";

    // Set a default mining speed if not set or zero
    if (currentSpeed.value == "0.0" || currentSpeed.value.isEmpty) {
      currentSpeed.value = "5.6";
    }

    if (Get.isRegistered<NotificationService>()) {
      Get.find<NotificationService>().scheduleMiningCompletionNotification(durationSeconds);
    }

    _localMiningTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.value > 0) {
        remainingTime.value--;
      } else {
        timer.cancel();
        dev.log("⏰ 24-Hour Timer finished! Auto-stopping...");
        _autoStopMiningSession();
      }
    });
  }

  Future<void> _autoStopMiningSession() async {
    // Automatically stop socket connection
    disconnectSocket();
    remainingTime.value = 0;
    status.value = "COMPLETED";

    try {
      isMiningLoading.value = true;
      addLog("🛑 Auto-stopping mining session (24h expired)...");
      await MiningRepo.stopMining();
      addLog("⏰ Auto-stop API called.");

      isMiningLoading.value = false;
      // Wait 1.5 seconds and fetch status to get latest balance
      await Future.delayed(const Duration(milliseconds: 1500));
      await fetchMiningStatus();
      status.value = "COMPLETED"; // Explicitly keep COMPLETED state
    } catch (e) {
      dev.log("Error during auto-stop: $e");
    } finally {
      isMiningLoading.value = false;
    }
  }

  final RxBool isMiningLoading = false.obs;

  Future<void> startMiningSession() async {
    if (status.value == "MINING" || isMiningLoading.value) {
      dev.log("⚠️ startMiningSession: Already mining or loading. Skipping call.");
      return;
    }

    try {
      isMiningLoading.value = true;
      addLog("🎬 Starting mining session...");

      // Call startMining using the updated model
      final StartMiningResponse? startResponse = await MiningRepo.startMining(adCompleted: true);
      if (startResponse != null && startResponse.success == true) {
        // Connect socket only after successful API call
        connectSocket();

        // Start local timer based on durationHours from response or default to 24 hours
        final durationHours = startResponse.data?.session?.durationHours ?? 24;
        totalSessionDuration.value = durationHours * 3600;
        startLocalMiningTimer(durationHours * 3600);

        if (startResponse.data?.session?.miningSpeed != null) {
          currentSpeed.value = startResponse.data!.session!.miningSpeed;
        }

        Get.snackbar(
          "Success",
          startResponse.message.isNotEmpty ? startResponse.message : "Mining session started successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        addLog("🚀 Mining session started successfully!");

        // Wait 1.5 seconds for the server to process the start request before updating status
        Future.delayed(const Duration(milliseconds: 1500), () {
          requestMiningStatus();
          fetchMiningStatus();
        });
      } else {
        _localMiningTimer?.cancel();
        remainingTime.value = 0;
        status.value = "IDLE";
        disconnectSocket();

        Get.snackbar(
          "Error",
          startResponse?.message ?? "Failed to start mining session",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        addLog("❌ Start mining failed: ${startResponse?.message}");
      }
    } catch (e) {
      _localMiningTimer?.cancel();
      remainingTime.value = 0;
      status.value = "IDLE";
      disconnectSocket();

      dev.log("Error starting mining session: $e");
      addLog("❌ Error: $e");
      Get.snackbar(
        "Error",
        "Something went wrong while starting mining",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      isMiningLoading.value = false;
    }
  }

  Future<void> stopMiningSession() async {
    if (isMiningLoading.value) {
      dev.log("⚠️ stopMiningSession: Already performing mining action. Skipping.");
      return;
    }

    // Immediately cancel local timer and reset variables to STOPPED
    _localMiningTimer?.cancel();
    remainingTime.value = 0;
    status.value = "STOPPED";

    if (Get.isRegistered<NotificationService>()) {
      Get.find<NotificationService>().cancelMiningCompletionNotification();
    }

    // Disconnect socket immediately
    disconnectSocket();

    try {
      isMiningLoading.value = true;
      addLog("🛑 Stopping mining session...");
      final StopMiningResponse? stopResponse = await MiningRepo.stopMining();
      if (stopResponse != null && stopResponse.success == true) {
        Get.snackbar(
          "Success",
          stopResponse.message.isNotEmpty ? stopResponse.message : "Mining session stopped.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        addLog("🛑 Mining session stopped.");
      } else {
        // Just log the error (e.g. 'No active mining session') but don't block the client reset
        addLog("⚠️ Server stop message: ${stopResponse?.message}");
        Get.snackbar(
          "Error",
          stopResponse?.message ?? "Failed to stop mining session",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
      isMiningLoading.value = false;
      // Wait 1.5 seconds and fetch status to get the final database value
      await Future.delayed(const Duration(milliseconds: 1500));
      await fetchMiningStatus();
      status.value = "STOPPED"; // Explicitly keep STOPPED state
    } catch (e) {
      dev.log("Error stopping mining: $e");
      addLog("❌ Error: $e");
    } finally {
      isMiningLoading.value = false;
    }
  }

  final RxMap<String, dynamic> miningStatus = <String, dynamic>{}.obs;
  final RxList<dynamic> miningHistory = <dynamic>[].obs;
  final RxBool isStatusLoading = false.obs;
  final RxBool isHistoryLoading = false.obs;

  Future<void> fetchMiningStatus() async {
    try {
      isStatusLoading.value = true;
      final response = await MiningRepo.getMiningStatus();
      if (response != null) {
        if (response['success'] == false &&
            (response['message']?.toString().toLowerCase().contains("token") == true ||
             response['message']?.toString().toLowerCase().contains("jwt") == true ||
             response['message']?.toString().toLowerCase().contains("unauthorized") == true)) {
          dev.log("🚨 Token expired/invalid inside fetchMiningStatus. Logging out...");
          Get.find<AuthController>().logout();
          return;
        }

        if (response['success'] == true) {
          if (isMiningLoading.value) {
            dev.log("⏳ fetchMiningStatus: Response ignored because start/stop API is in progress.");
            return;
          }
          final data = response['data'] ?? response;
          miningStatus.value = data is Map<String, dynamic> ? data : {};

          // Map the retrieved status keys directly to the reactive observables
          if (data != null && data is Map) {
            final serverMiningBalance = data['currentMiningBalance'] ?? data['miningBalance'];
            final serverEarned = data['currentEarned'] ?? data['earned'];

            double baseBal = 0.0;
            if (serverMiningBalance != null) {
              baseBal = double.tryParse(serverMiningBalance.toString()) ?? 0.0;
            }

            double earnedBal = 0.0;
            if (serverEarned != null) {
              earnedBal = double.tryParse(serverEarned.toString()) ?? 0.0;
            }

            double totalBal = baseBal + earnedBal;
            currentMiningBalance.value = totalBal.toStringAsFixed(18);

            if (serverEarned != null) {
              if (serverEarned is num) {
                currentEarned.value = serverEarned.toStringAsFixed(18);
              } else {
                currentEarned.value = serverEarned.toString();
              }
            }

            final serverSpeed = data['currentSpeed'] ?? data['speed'];
            if (serverSpeed != null) {
              currentSpeed.value = serverSpeed.toString();
            }

            final serverStatus = data['status'];
            if (serverStatus != null) {
              final String serverStatusStr = serverStatus.toString();
              if (serverStatusStr == "MINING") {
                status.value = "MINING";
              } else if (status.value != "STOPPED" && status.value != "COMPLETED") {
                status.value = serverStatusStr;
              }
            }

            // Calculate total session duration dynamically
            int sessionDuration = 86400; // default 24h
            dynamic rawStart = data['startTime'] ?? data['session']?['startTime'];
            dynamic rawEnd = data['endTime'] ?? data['session']?['endTime'];
            if (rawStart != null && rawEnd != null) {
              final start = DateTime.tryParse(rawStart.toString());
              final end = DateTime.tryParse(rawEnd.toString());
              if (start != null && end != null) {
                sessionDuration = end.difference(start).inSeconds;
              }
            } else {
              dynamic rawDuration = data['durationHours'] ?? data['session']?['durationHours'];
              if (rawDuration != null) {
                final parsed = int.tryParse(rawDuration.toString());
                if (parsed != null) {
                  sessionDuration = parsed * 3600;
                }
              }
            }
            if (sessionDuration > 0) {
              totalSessionDuration.value = sessionDuration;
            }

            final serverRemaining = data['remainingTime'] ?? data['timeRemaining'];
            if (serverRemaining != null) {
              int timeInSeconds = 0;
              if (serverRemaining is int) {
                timeInSeconds = serverRemaining;
              } else if (serverRemaining is double) {
                timeInSeconds = serverRemaining.toInt();
              } else {
                timeInSeconds = int.tryParse(serverRemaining.toString()) ?? 0;
              }

              // Only overwrite remainingTime if client timer is not active, OR if the server has a positive remaining time
              if (remainingTime.value == 0 || timeInSeconds > 0) {
                remainingTime.value = timeInSeconds;

                final bool isTimerActive = _localMiningTimer != null && _localMiningTimer!.isActive;
                // If the status is MINING and timeRemaining is active, start ticking down locally
                if (status.value == "MINING" && timeInSeconds > 0 && !isTimerActive) {
                  connectSocket(); // Connect socket for active session
                  startLocalMiningTimer(timeInSeconds, resetBalance: false);
                }
              }
            }
          }
        }
        addLog("📊 Status fetched successfully.");
      }
    } catch (e) {
      dev.log("Error fetching mining status: $e");
    } finally {
      isStatusLoading.value = false;
    }
  }

  Future<void> fetchMiningHistory() async {
    try {
      isHistoryLoading.value = true;
      final response = await MiningRepo.getMiningHistory();
      if (response != null) {
        if (response['success'] == false &&
            (response['message']?.toString().toLowerCase().contains("token") == true ||
             response['message']?.toString().toLowerCase().contains("jwt") == true ||
             response['message']?.toString().toLowerCase().contains("unauthorized") == true)) {
          dev.log("🚨 Token expired/invalid inside fetchMiningHistory. Logging out...");
          Get.find<AuthController>().logout();
          return;
        }

        if (response['success'] == true) {
          final listData = response['data'];
        if (listData is List) {
          miningHistory.value = listData;
        } else if (response['history'] is List) {
          miningHistory.value = response['history'];
        }
        }
        addLog("📜 History fetched successfully.");
      }
    } catch (e) {
      dev.log("Error fetching mining history: $e");
    } finally {
      isHistoryLoading.value = false;
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    disconnectSocket();
    super.onClose();
  }
}
