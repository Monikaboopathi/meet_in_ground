import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String sender;
  String receiver;
  Timestamp timestamp;
  String message;
  String senderImage;
  String recieverImage;
  String senderName;
  String receiverName;
  final roomId;
  final isRead;

  Message({
    required this.sender,
    required this.receiver,
    required this.timestamp,
    required this.message,
    required this.receiverName,
    required this.recieverImage,
    required this.senderImage,
    required this.senderName,
    this.roomId,
    this.isRead,
  });

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'receiver': receiver,
      'timestamp': timestamp,
      'message': message,
      'receiverName': receiverName,
      'recieverImage': recieverImage,
      'senderImage': senderImage,
      'senderName': senderName,
      'isRead': isRead
    };
  }

  static Message fromMap(Map<String, dynamic> map) {
    return Message(
      sender: map['sender'] ?? 'Unknown sender',
      receiver: map['receiver'] ?? 'Unknown receiver',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      message: map['message'] ?? '',
      receiverName: map['receiverName'] ?? 'Unknown receiver name',
      recieverImage: map['recieverImage'] ?? '',
      senderImage: map['senderImage'] ?? '',
      senderName: map['senderName'] ?? 'Unknown sender name',
      isRead: map['isRead'] ?? false,
    );
  }
}
