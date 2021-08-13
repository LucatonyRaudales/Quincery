import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:quincey_app/models/messages.dart';

class HomeRepository {
  final box = GetStorage();
  String token =
      "2mBC92xBrVixmwzHJRPquFS9uUMnDb5YRwRYNfdC3bEQFxjXjmnX6JSe9CYzxvhz";
  String _urlBase = "https://sms.aguacate.studio/api/SMS/";

  Future setPasswod({String password}) async {
    var url = Uri.parse('https://sms.aguacate.studio/api/SMS/');
    var res = await http.post(url);
  }

  Future<Response> getMessages({String token}) async {
    /*
    [HttpGet]
    https://sms.aguacate.studio/api/SMS/readMessages/
    Params: token = Z4U-VYY-6be-Rh5 o este otro LDP-yzq-PFt-Pvv
    (esta es la contraseña que ponés en el teléfono y te mando dos)

    recibís esto:
    { "id": 1, "phone": "xxxxxxxx", "message": "xxxx" } 
    te va a mandar un límite de 10 mensajes para no mamar la consulta y no mamar el pool*/

    var url = Uri.parse(
        "https://sms.aguacate.studio/api/SMS/readMessages?token=$token");
    var res = await http.get(url);
    print("respuesta del token: $token es: ${res.statusCode}");
    return res;
  }

  Future<bool> changeStatusMessage({int id, bool status, String token}) async {
    var url = Uri.parse(_urlBase + "statusMessage/");
    var res = await http.put(url,
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },
        body: json.encode({
          "Id": id.toString(),
          "Status": status.toString(),
          "Token": token
        }));

    print(
        "ID message: $token actualizado con el status: $status respuesta:${res.statusCode}");
    return res.statusCode == 201;
  }

  Future saveKey({String key}) async {
    print(key);
    if (box.hasData("key")) {
      box.remove('key');
    }
    return box.write('key', key);
  }

  Future<String> getKey() async {
    return box.read('key');
  }

  Future<bool> haveKey() async {
    bool have = box.hasData("key") && box.read("key") != "";
    print("key: ${box.read("key")}");
    return have;
  }
}
