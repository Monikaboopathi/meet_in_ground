import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String sender;
  String receiver;
  Timestamp timestamp;
  String message;

  Message({
    required this.sender,
    required this.receiver,
    required this.timestamp,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'receiver': receiver,
      'timestamp': timestamp,
      'message': message,
    };
  }

  static Message fromMap(Map<String, dynamic> map) {
    return Message(
      sender: map['sender'],
      receiver: map['receiver'],
      timestamp: map['timestamp'],
      message: map['message'],
    );
  }
}
