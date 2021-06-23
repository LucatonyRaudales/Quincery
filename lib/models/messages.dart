class Messages {
  Messages({
     this.messages,
  });

  List<Message> messages;

  factory Messages.fromJson(List<dynamic> json) {
    List<Message> mensajes;
    mensajes = json.map((i) => Message.fromJson(i)).toList();
    return new Messages(messages: mensajes);
  }
}

class Message {
  Message({
     this.id,
     this.phone,
     this.message,
     this.status
  });

  int id;
  String phone;
  String message;
  int status;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
      id: json["id"],
      phone: json["phone"],
      message: json["message"],
      status: 0);

  Map<String, dynamic> toJson() => {
        "id": id,
        "phone": phone,
        "message": message,
      };
}
