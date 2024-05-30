import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meet_in_ground/Models/Message.dart';

class Chatservice extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(
    String receiverId,
    String message,
    String receiverName,
    String receiverImage,
  ) async {
    final String currentUserId = "8072974576";
    final String senderName = "Ranjith";
    final String senderImage = "";
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      sender: currentUserId,
      receiver: receiverId,
      timestamp: timestamp,
      message: message,
      receiverName: receiverName,
      recieverImage: receiverImage,
      senderImage: senderImage,
      senderName: senderName,
    );
    print(newMessage);
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("-");

    await _firestore
        .collection('rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String otherUserId) {
    final String currentUserId = "8072974576";
    List<String> ids = [currentUserId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("-");

    return _firestore
        .collection('rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> getAllMessagesAndRooms(
      String senderId) async {
    QuerySnapshot roomsSnapshot = await _firestore.collection('rooms').get();

    List<Map<String, dynamic>> allMessagesAndRooms = [];
    print("===============");
    for (var room in roomsSnapshot.docs) {
      print("===============");
      String roomId = room.id;
      print(roomId);
      QuerySnapshot messagesSnapshot = await _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .where('sender', isEqualTo: senderId)
          .orderBy('timestamp', descending: false)
          .get();

      List<Message> messages = messagesSnapshot.docs
          .map((doc) => Message.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      allMessagesAndRooms.add({
        'roomId': roomId,
        'messages': messages,
      });

      // Print room details and its messages
      print("Room ID: $roomId");
      for (var message in messages) {
        print("Message: ${message.message}");
        // You can print other message details here if needed
      }
    }

    return allMessagesAndRooms;
  }
}
