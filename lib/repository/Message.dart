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

  Future<Response> setMessage({String phone, String message}) async {
    /*
    [POST]
      https://sms.aguacate.studio/api/SMS/helloMessage
      { "Phone":"xxxx-xxxx", "Message":"xxxx", "Token": "2mBC92xBrVixmwzHJRPquFS9uUMnDb5YRwRYNfdC3bEQFxjXjmnX6JSe9CYzxvhz" }

      desde ahí podés inyectar números al API
      responde:  true / BadRequest + detalle del error
    */

    var url = Uri.parse(_urlBase + "helloMessage");
    var res = await http
        .post(url, body: {"Phone": phone, "Message": message, "Token": token});

    return res;
  }

  Future<Response> getMessages({String password}) async {
    Messages _messages = Messages();
    /*
    [HttpGet]
    https://sms.aguacate.studio/api/SMS/readMessages/
    Params: token = Z4U-VYY-6be-Rh5 o este otro LDP-yzq-PFt-Pvv
    (esta es la contraseña que ponés en el teléfono y te mando dos)

    recibís esto:
    { "id": 1, "phone": "xxxxxxxx", "message": "xxxx" } 
    te va a mandar un límite de 10 mensajes para no mamar la consulta y no mamar el pool*/

    var url = Uri.parse(
        "https://sms.aguacate.studio/api/SMS/readMessages?token=Z4U-VYY-6be-Rh5");
    var res = await http.get(url);
    return res;
  }

  Future<bool> changeStatusMessage({int id, bool status}) async {
    /*
    [HttpGet]
    https://sms.aguacate.studio/api/SMS/readMessages/
    Params: token = Z4U-VYY-6be-Rh5 o este otro LDP-yzq-PFt-Pvv
    (esta es la contraseña que ponés en el teléfono y te mando dos)

    recibís esto:
    { "id": 1, "phone": "xxxxxxxx", "message": "xxxx" } 
    te va a mandar un límite de 10 mensajes para no mamar la consulta y no mamar el pool*/

    var url = Uri.parse(_urlBase + "statusMessage/");
    var res = await http.put(url,
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },
        body: json.encode({
          "Id": id.toString(),
          "Status": status.toString(),
          "Token": "Z4U-VYY-6be-Rh5"
        }));

    print(
        "ID message: $id actualizado con el status: $status respuesta:${res.statusCode}");
    return res.statusCode == 201;
  }

  Future saveKey({String key}) async {
    print(key);
    return box.write('key', key);
  }

  Future<String> getKey() async {
    return box.read('key');
  }

  Future<bool> haveKey() async {
    bool have =  box.hasData("key");
    return have;
  }
}
