import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:quincey_app/controllers/home.ctrl.dart';
import 'package:workmanager/workmanager.dart';
import 'components/myButton.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    print("Background iniciadop "); //simpleTask will be emitted here.
    MessageCtrl().getSendAndSaveData();
    return Future.value(true);
  });
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageCtrl>(
        init: MessageCtrl(),
        builder: (_ctrl) => Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text("SMS Sender"),
                actions: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: GestureDetector(
                        onTap: () => _ctrl.validateKey(),
                        child: Icon(Icons.refresh),
                      )),
                ],
              ),
              body: SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                physics: ScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Center(
                                child: ListTile(
                          title: new Text(_ctrl.smsSent.toString(),
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          subtitle: new Text("Enviados",
                              style: TextStyle(
                                  color: Colors.grey[850],
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                        ))),
                        Expanded(
                            child: ListTile(
                          title: new Text(_ctrl.smsFails.toString(),
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          subtitle: new Text("No enviados",
                              style: TextStyle(
                                  color: Colors.grey[850],
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                        ))
                      ],
                    ),
                    SizedBox(height: 15),
                    new Text(_ctrl.isActive ? "Activo" : "Sin Conexión",
                        style: TextStyle(
                            color: _ctrl.isActive ? Colors.green : Colors.red,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    SizedBox(height: 15),
                    ExpansionTile(
                      title: Text(
                        "Editar clave",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      children: <Widget>[
                        Container(
                          height: 45,
                          child: new TextFormField(
                              initialValue: _ctrl.token,
                              onChanged: (va) => _ctrl.message.key = va,
                              decoration: InputDecoration(
                                  hintText: "Clave o Contraseña",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: Colors.white70,
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(22)),
                                      borderSide: BorderSide(
                                          color: Colors.blueGrey, width: 1)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      borderSide:
                                          BorderSide(color: Colors.blueGrey)))),
                        ),
                        SizedBox(height: 15),
                        MyButton(
                          buttonController: _ctrl.btnController,
                          onPressed: () => _ctrl.saveKey(),
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                        SizedBox(height: 15),

                    _ctrl.lMs.messages.isEmpty
                        ? new Text("No hay mensajes disponibles para el envío",
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.bold))
                        : ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _ctrl.lMs.messages.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                  title: new Text(
                                    _ctrl.lMs.messages[index].message,
                                    style: TextStyle(
                                        color: Colors.blueGrey[800],
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
                                        overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle:
                                      new Text(_ctrl.lMs.messages[index].phone,
                                    style: TextStyle(
                                        color: Colors.blueGrey[600],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700),),
                                  trailing: _ctrl.lMs.messages[index].status ==
                                          3
                                      ? SizedBox(
                                          height: 15,
                                          width: 15,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.grey,
                                            backgroundColor: Colors.white,
                                          ),
                                        )
                                      : new Icon(
                                          Icons.circle_notifications_outlined,
                                          color: _ctrl.lMs.messages[index]
                                                      .status ==
                                                  0
                                              ? Colors.grey
                                              : _ctrl.lMs.messages[index]
                                                          .status ==
                                                      1
                                                  ? Colors.green
                                                  : Colors.red));
                            })
                    //futureBuilder(),
                  ],
                ),
              )),
            ));
  }
}

class Message {
  Message({this.phone, this.message, this.token, this.key});

  String phone;
  String message;
  String token;
  String key;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
      phone: json["Phone"],
      message: json["Message"],
      token: json["Token"],
      key: json["key"]);

  Map<String, dynamic> toJson() =>
      {"Phone": phone, "Message": message, "Token": token, "key": key};
}
