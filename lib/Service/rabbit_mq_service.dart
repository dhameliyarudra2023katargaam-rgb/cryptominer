// import 'dart:async';
// import 'dart:developer';
// import 'dart:ui';
//
// import 'package:dart_amqp/dart_amqp.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:luna/api/api_end_points.dart';
// import 'package:luna/services/socket%20model/commonSocket_model.dart';
// import 'package:luna/services/socket%20model/getById_model.dart';
// import 'package:luna/services/socket%20model/newcall_request_model.dart';
// import 'package:luna/services/socket_services.dart';
// import 'package:luna/services/storage_services.dart';
//
// import '../Screens/Screen/Dashboard/controller/dashboard_controller.dart';
// import '../api/repo class/call_repo.dart';
// import '../widget_common/common_widget.dart';
// import '../widget_common/loader.dart';
//
// class RabbitMQService extends GetxService {
//   Client? _client;
//   Channel? _channel;
//   Queue? _queue;
//   DashboardController? dashboardController;
//   SocketService? socketServices;
//
//   RabbitMQService({this.socketServices, this.dashboardController});
//
//   AmqpMessage? message;
//
//   // @override
//   // void onInit() {
//   //   log("1112222111111111111111111111");
//   //   if (!Get.isRegistered<SocketService>()) {
//   //     socketServices = Get.put(SocketService(), permanent: true);
//   //   }
//   //   log("333333333333333333333333333333");
//   //
//   //   socketServices = Get.find<SocketService>();
//   //   super.onInit();
//   // }
//
//   Timer? timer;
//   Rxn<NewCallRequestModel> newCallRequestModel = Rxn<NewCallRequestModel>();
//
//   Future<void> connectAndConsume() async {
//     try {
//       _client = Client(
//         settings: ConnectionSettings(
//           host: BaseService.rabbitMQURL,
//           port: BaseService.rabbitMQPort,
//         ),
//       );
//
//       _channel = await _client!.channel();
//
//       _queue = await _channel!.queue(
//         "request_queue",
//         durable: false,
//       );
//       Consumer consumer = await _queue!.consume(noAck: false);
//       consumer.listen((AmqpMessage msg) async {
//         final dashboardController = Get.find<DashboardController>();
//
//         log("Received message: ${msg.payloadAsString}");
//         log("sdflksdfisddasdasdsdf ::: ${dashboardController?.isAgentAvailable?.value}");
//
//         try {
//           if (dashboardController.isAgentAvailable?.value != 1) {
//             msg.reject(true);
//             log("sdflksdfisdf ::: ${dashboardController.isAgentAvailable}");
//           } else {
//             message = msg;
//             // updateCallRequest(message.payloadAsJson);
//             newCallRequestModel.value = NewCallRequestModel.fromJson(msg.payloadAsJson);
//
//             GetByIdModel responseModel = await CallRepo.reqGetByIdRepo({"requestId": newCallRequestModel.value?.requestId});
//
//             if (responseModel.isSuccess ?? false) {
//               if (responseModel.data?.status == 4 || responseModel.data?.status == 5) {
//                 message?.ack();
//               } else {
//                 if (newCallRequestModel.value != null) {
//                   socketServices?.socket.off('request-closed');
//                   socketServices?.socket.on('request-closed', (data) {
//                     print('📡 Event: request-closed -> Data: $data');
//                     CommonSocketModel commonSocketModel = CommonSocketModel.fromJson(data);
//
//                     String? reqID = SharedPrefHelper.getString("requestId");
//                     if (commonSocketModel.request == reqID) {
//                       if (dashboardController.isAgentAvailable?.value == 2) {
//                         timer?.cancel();
//                         message?.ack();
//                         Get.back();
//                       }
//                       dashboardController.isAgentAvailable?.value = 1;
//                     }
//                   });
//
//                   // socketServices?.socket.off('request-ended');
//                   // socketServices?.socket.on('request-ended', (data) {
//                   //   print('📡 Event: request-ended -> Data: $data');
//                   //   message?.ack();
//                   //   Get.toNamed(Routes.SUMMARYVIEW, arguments: dashboardController?.callController);
//                   // });
//
//                   dashboardController.callController?.setRequestId(requestId: newCallRequestModel.value?.requestId.toString());
//                   await SharedPrefHelper.setString("requestId", newCallRequestModel.value?.requestId ?? "");
//                   dashboardController.isAgentAvailable?.value = 2;
//                   showDialog(
//                     context: Get.context!,
//                     barrierDismissible: false,
//                     barrierColor: Colors.black.withOpacity(0.3),
//                     builder: (context) {
//                       return BackdropFilter(
//                         filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//                         child: commonCallDialog(
//                             phone: newCallRequestModel.value?.phone.toString() ?? "",
//                             location: newCallRequestModel.value?.location?.location.toString() ?? "",
//                             city: newCallRequestModel.value?.location?.city.toString() ?? "",
//                             state: newCallRequestModel.value?.location?.state.toString() ?? "",
//                             onAccept: () {
//                               timer?.cancel();
//                               // dashboardController?.socketServices?.acceptRequestAgent(
//                               //     SharedPrefHelper.getString("token").toString(),
//                               //     newCallRequestModel.value?.requestId.toString() ?? "")
//                               CustomLoading.progressDialog(isLoading: true);
//                               dashboardController.socketServices
//                                   ?.acceptRequestAgent(SharedPrefHelper.getString("requestId").toString());
//                             },
//                             onReject: () async {
//                               timer?.cancel();
//                               message?.reject(true);
//                               dashboardController.isAgentAvailable?.value = 1;
//                               socketServices?.declineRequestAgent(newCallRequestModel.value?.requestId ?? "");
//                               Get.back();
//                             }
//                           // onReject: () {
//                           //   _timer?.cancel();
//                           //   message?.reject(true);
//                           //   dashboardController.isAgentAvailable = 1;
//                           //   closeConnection();
//                           //   connectAndConsume();
//                           //   // socketServices?.declineRequestAgent(SharedPrefHelper.getString("token").toString());
//                           //   Get.back();
//                           // },
//                         ),
//                       );
//                     },
//                   );
//                   // dashboardController?.update(["dashBoard"]);
//                 }
//
//                 timer = Timer(Duration(seconds: 30), () {
//                   message?.reject(true);
//                   dashboardController.isAgentAvailable?.value = 1;
//                   socketServices?.declineRequestAgent(newCallRequestModel.value?.requestId ?? "");
//                   Get.back();
//                 });
//               }
//             } else {
//               message?.ack();
//               showSnackBar(responseModel.message.toString());
//             }
//           }
//         } catch (e) {
//           log("Error in rabbitMQ ::::::: $e");
//         }
//       });
//     } catch (e) {
//       print("Error connecting to RabbitMQ: $e");
//     }
//   }
//
//   void closeConnection() {
//     _client?.close();
//   }
//
//   void msgAck() {
//     timer?.cancel();
//     message?.ack();
//     Get.back();
//   }
//
//   void cancelTimer() {
//     timer?.cancel();
//     print("Timer cancelled!");
//   }
//
//   Future<void> resetConnection() async {
//     try {
//       await _client?.close();
//       _client = null;
//       _channel = null;
//       _queue = null;
//       message = null;
//       print("RabbitMQ connection reset.");
//     } catch (e) {
//       print("Error resetting RabbitMQ connection: $e");
//     }
//   }
// }
