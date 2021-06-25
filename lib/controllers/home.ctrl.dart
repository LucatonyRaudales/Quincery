import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:quincey_app/models/messages.dart';
import 'package:quincey_app/repository/Message.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sms_maintained/sms.dart';

class MessageCtrl extends GetxController {
  HomeRepository _homeRepository = new HomeRepository();
  Message message = new Message();
  SmsSender sender = new SmsSender();
  Messages lMs = new Messages(messages: []);
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

  void validateKey() async {
    smsToSend = 0;
    bool have = await _homeRepository.haveKey();
    if (have) {
      await getKey();
      /*
    Workmanager().cancelAll();
    print("registrando");
    Workmanager().initialize(
    callbackDispatcher, // The top level function, aka callbackDispatcher
    isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
    ).then((value)async{
  await Workmanager().registerPeriodicTask(
    "1",
    "task1",
    constraints: Constraints(
        networkType: NetworkType.connected,
    ),
    initialDelay: Duration(seconds: 5),
    frequency: Duration(minutes: 7));
    });
      */
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
      Timer(Duration(seconds: 3), () {
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
      if (lMs.messages.isEmpty) return null;
      _sendSMS();
    } else if(res.statusCode == 400){
      isActive = true;
      final snackBar = SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text('¡CLAVE INCORRECTA!. ingresa una clave válida'));
      ScaffoldMessenger.of(Get.context).showSnackBar(snackBar);
    }else{
      isActive = false;
    }
    update();
  }

  void _sendSMS() async {
    if (smsToSend < lMs.messages.length) {
      lMs.messages[smsToSend].status = 3;
      update();

      print("pasa por aqui indx: $smsToSend");
      SmsMessage message = new SmsMessage(
          lMs.messages[smsToSend].phone, lMs.messages[smsToSend].message);

      message.onStateChanged.timeout(Duration(seconds: 15),
          onTimeout: (timeout) {
        timeout.close();
        print("mucho tiempo");
         changeStatus(status: false, index: smsToSend);
      }).listen((state) async {
        print(state);
        if (state == SmsMessageState.Sent) {
              print("SMS is sent!");
              changeStatus(status: true, index: smsToSend - 1);
            }

        if (state == SmsMessageState.Fail) {
          print("falló");
          changeStatus(status: false, index: smsToSend - 1);
        }
      }, onError: (err) {
        print("Error: $err");
        changeStatus(status: false, index: smsToSend);
      }, onDone: () {
        print("on done, cambio de mensaje");
        //changeStatus(status: true, index: smsToSend);
      }, cancelOnError: true);
      await sender.sendSms(message);
    } else {
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
