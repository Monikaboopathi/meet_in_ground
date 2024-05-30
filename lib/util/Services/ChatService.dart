
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meet_in_ground/Models/Message.dart';

class Chatservice extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = "8072974576";
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      sender: currentUserId,
      receiver: receiverId,
      timestamp: timestamp,
      message: message,
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<List<String>> getChatRoomIds() async {
    var querySnapshot = await _firestore.collection('chat_rooms').get();
    var chatRooms = querySnapshot.docs;
    print(chatRooms);
    List<String> roomIds = [];
    chatRooms.forEach((room) {
      roomIds.add(room.id);
      print(room.id.toString());
    });

    return roomIds;
  }


}
