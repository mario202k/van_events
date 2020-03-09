import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String idFrom;
  final String idTo;
  final String message;
  final DateTime date;
  final int type;
  final int state;

  Message(
      {this.id,
        this.idFrom,
        this.idTo,
        this.message,
        this.date,
        this.type,
        this.state});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idFrom': idFrom,
      'idTo': idTo,
      'message': message,
      'date': date,
      'type': type,
      'state': state,
    };
  }


  factory Message.fromMap(Map data) {
    Timestamp time = data['date'] ?? '';

    return Message(
        id: data['id'] ?? '',
        idFrom: data['idFrom'] ?? '',
        idTo: data['idTo'] ?? '',
        message: data['message'] ?? '',
        date: time.toDate() ?? '',
        type: data['type'] ?? '',
        state: data['state'] ?? '');
  }
}
