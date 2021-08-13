import 'dart:async';
import 'dart:convert';
import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:quincey_app/models/messages.dart';
import 'package:quincey_app/repository/Message.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sms_maintained/sms.dart';
import 'package:permission_handler/permission_handler.dart';

class MessageCtrl extends GetxController {
  HomeRepository _homeRepository = new HomeRepository();
  Message message = new Message();
  SmsSender sender = new SmsSender();
  Messages lMs = new Messages(messages: []);
  RxInt secondsToCall = 10.obs;
  int smsToSend = 0, smsSent = 0, smsFails = 0;
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();
  bool permissionsGranted = false, isActive = false;
  String token = "";
  @override
  void onInit() {
    validateKey();
    super.onInit();
  }

  _getPermission() async => await [
        Permission.sms,
      ].request();

  Future<bool> _isPermissionGranted() async =>
      await Permission.sms.status.isGranted;

  Future<bool> get _supportCustomSim async =>
      await BackgroundSms.isSupportCustomSim;

  void validateKey() async {
    _getPermission();
    bool permiso = await _isPermissionGranted();
    print("hay permiso: $permiso");
    bool customSIm = await _supportCustomSim;
    print("hay custom: $customSIm");

    smsToSend = 0;
    bool have = await _homeRepository.haveKey();
    if (have) {
      await getKey();
      getSendAndSaveData();
    } else {
      final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text('¡CLAVE VACÍA!. ingresa una clave'));
      ScaffoldMessenger.of(Get.context).showSnackBar(snackBar);
    }
  }

  void saveKey() {
    _homeRepository.saveKey(key: message.key).then((value) {
      btnController.success();
      Timer(Duration(seconds: 1), () {
        btnController.reset();
        validateKey();
      });
    });
  }

  Future getKey() {
    _homeRepository.getKey().then((value) {
      token = value;
      print(token);
      update();
    });
    return null;
  }

  void getSendAndSaveData() async {
    print("enviado token: $token");
    smsToSend = 0;
    lMs.messages.clear();
    var res = await _homeRepository.getMessages(token: token);
    if (res.statusCode == 200) {
      isActive = true;
      var decode = json.decode(res.body);
      lMs = Messages.fromJson(decode);
      update();
      if (lMs.messages.isEmpty) {
        print("secondsToCall: $secondsToCall.value");
        Timer(Duration(seconds: secondsToCall.value), () => getSendAndSaveData());
        return null;
      }
      _sendSMS();
    } else if (res.statusCode == 400) {
      isActive = true;
      final snackBar = SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text('¡CLAVE INCORRECTA!. ingresa una clave válida'));
      ScaffoldMessenger.of(Get.context).showSnackBar(snackBar);
    } else {
      isActive = false;
    }
    update();
  }

  void _sendSMS() async {
    if (smsToSend < lMs.messages.length) {
      lMs.messages[smsToSend].status = 3;
      update();

      SmsMessage message = new SmsMessage(
          lMs.messages[smsToSend].phone, lMs.messages[smsToSend].message);
      var result = await BackgroundSms.sendMessage(
          phoneNumber: lMs.messages[smsToSend].phone,
          message: lMs.messages[smsToSend].message,
          simSlot: 0);
      if (result == SmsStatus.sent) {
        print("SMS is sent!");
        changeStatus(status: true, index: smsToSend);
      } else {
        print("falló");
        changeStatus(status: false, index: smsToSend);
      }
      await sender.sendSms(message);
    } else {
      print("obteniendo data");
      getSendAndSaveData();
    }
  }

  void changeStatus({bool status, int index}) async {
    await _homeRepository.changeStatusMessage(
        id: lMs.messages[index].id, status: status, token: message.key);
    if (status) {
      lMs.messages[index].status = 1;
      smsSent++;
    } else {
      lMs.messages[index].status = 2;
      smsFails++;
    }
    smsToSend++;
    update();
    Timer(Duration(seconds: 2), () => _sendSMS());
  }
}

class Message {
  Message({this.phone, this.token, this.key});

  String phone;
  String token;
  String key;

  factory Message.fromJson(Map<String, dynamic> json) =>
      Message(phone: json["Phone"], token: json["Token"], key: json["key"]);

  Map<String, dynamic> toJson() => {"Phone": phone, "Token": token, "key": key};
}
