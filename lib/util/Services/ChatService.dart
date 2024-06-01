import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meet_in_ground/Models/Message.dart';
import 'package:meet_in_ground/util/Services/image_service.dart';
import 'package:meet_in_ground/util/Services/mobileNo_service.dart';
import 'package:meet_in_ground/util/Services/userName_service.dart';

class Chatservice extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> _getCurrentUserId() async {
    try {
      String? mobileNumber = await MobileNo.getMobilenumber();
      if (mobileNumber != null) {
        return mobileNumber;
      } else {
        throw Exception("Mobile number is null");
      }
    } catch (e) {
      print("Error fetching mobile number: $e");
      throw Exception("Failed to get current user's mobile number");
    }
  }

  Future<String> _getUserImage() async {
    try {
      String? image = await ImageService.getImage();
      if (image != null) {
        return image;
      } else {
        throw Exception("Mobile number is null");
      }
    } catch (e) {
      print("Error fetching mobile number: $e");
      throw Exception("Failed to get current user's mobile number");
    }
  }

  Future<String> _getUsername() async {
    try {
      String? username = await UsernameService.getUserName();
      if (username != null) {
        return username;
      } else {
        throw Exception("Mobile number is null");
      }
    } catch (e) {
      print("Error fetching mobile number: $e");
      throw Exception("Failed to get current user's mobile number");
    }
  }

  Future<void> sendMessage(
    String receiverId,
    String message,
    String receiverName,
    String receiverImage,
  ) async {
    final String currentUserId = await _getCurrentUserId();
    final String senderName = await _getUsername();
    final String senderImage = await _getUserImage();
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

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("-");

    await _firestore
        .collection('rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String otherUserId) async* {
    final String currentUserId = await _getCurrentUserId();
    List<String> ids = [currentUserId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("-");

    yield* _firestore
        .collection('rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getMessages1() async* {
    yield* _firestore
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> getAllMessagesAndRooms() async {
    try {
      getMessages1().listen(
        (QuerySnapshot snapshot) {
          snapshot.docs.forEach((DocumentSnapshot doc) {
            print(doc.data()); // This will print the data of each document
          });
        },
        onError: (error) => print('Error fetching messages: $error'),
      );
      testFirestoreAccess();
      getAllRoomIds();
      final String currentUserId = await _getCurrentUserId();
      print("Current User ID: $currentUserId");

      QuerySnapshot roomsSnapshot = await _firestore.collection('rooms').get();
      print("Rooms Snapshot: ${roomsSnapshot.size} rooms found.");

      if (roomsSnapshot.size == 0) {
        print("No rooms found in the 'rooms' collection.");
      }

      List<Map<String, dynamic>> allMessagesAndRooms = [];
      for (var room in roomsSnapshot.docs) {
        String roomId = room.id;
        print("Processing Room ID: $roomId");

        QuerySnapshot messagesSnapshot = await _firestore
            .collection('rooms')
            .doc(roomId)
            .collection('messages')
            .where('sender', isEqualTo: currentUserId)
            .orderBy('timestamp', descending: false)
            .get();

        print(
            "Messages Snapshot: ${messagesSnapshot.size} messages found for Room ID: $roomId");

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
        }
      }

      print("All messages and rooms processed successfully.");
      return allMessagesAndRooms;
    } catch (e) {
      print("An error occurred: $e");
      return [];
    }
  }

  void testFirestoreAccess() async {
    try {
      DocumentSnapshot testDoc = await _firestore
          .collection('rooms')
          .doc('+918072974572-8072974576')
          .get();
      if (testDoc.exists) {
        print("Test document data: ${testDoc.data()}");
      } else {
        print("Test document does not exist.");
      }
    } catch (e) {
      print("Error accessing Firestore: $e");
    }
  }

  Future<List<String>> getAllRoomIds() async {
    try {
      print("Fetching room IDs...");
      QuerySnapshot roomsSnapshot =
          await FirebaseFirestore.instance.collection('rooms').get();
      print("Rooms Snapshot: ${roomsSnapshot.size} rooms found.");

      if (roomsSnapshot.size == 0) {
        print("No rooms found in the 'rooms' collection.");
      }

      List<String> roomIds = [];

      // Iterate through each room document
      for (var roomDoc in roomsSnapshot.docs) {
        String roomId = roomDoc.id;
        print("Processing Room ID: $roomId");

        // Query the messages subcollection of each room
        QuerySnapshot messagesSnapshot = await FirebaseFirestore.instance
            .collection('rooms')
            .doc(roomId)
            .collection('messages')
            .get();

        // If the messages subcollection exists, add the room ID to the list
        if (messagesSnapshot.docs.isNotEmpty) {
          roomIds.add(roomId);
        }
      }

      print("Room IDs: $roomIds");
      return roomIds;
    } catch (e) {
      print("An error occurred while fetching room IDs: $e");
      return []; // Or handle the error in an appropriate way
    }
  }
}
