import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:quincey_app/views/home_view.dart';
void main() async{
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'sms sender',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: HomeView(),
    );
  }
}
