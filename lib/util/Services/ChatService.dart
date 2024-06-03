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

  Future<void> _createRoom(String roomId) async {
    try {
      await FirebaseFirestore.instance.collection('rooms').doc(roomId).set({
        // Add any initial data you want to set for the room
      });
      print('Room created successfully');
    } catch (e) {
      print('Error creating room: $e');
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
        sender: "+91" + currentUserId,
        receiver: receiverId,
        timestamp: timestamp,
        message: message,
        receiverName: receiverName,
        recieverImage: receiverImage,
        senderImage: senderImage,
        senderName: senderName,
        roomId: "+91" + currentUserId + "-" + receiverId);

    List<String> ids = ["+91" + currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("-");

    // Check if the 'rooms' collection exists, create it if not
    final roomsCollection = _firestore.collection('rooms');
    final roomDoc = roomsCollection.doc(chatRoomId);
    final roomExists = await roomDoc.get().then((doc) => doc.exists);
    if (!roomExists) {
      await _createRoom(chatRoomId);
    }

    // Add the message to the 'messages' subcollection of the room
    final messagesCollection = roomDoc.collection('messages');
    await messagesCollection.add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String otherUserId) async* {
    final String currentUserId = await _getCurrentUserId();
    List<String> ids = ["+91" + currentUserId, otherUserId];
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
    List<Map<String, dynamic>> chatRooms = [];
    print("print 1");

    final String currentUserId = await _getCurrentUserId();

    try {
      QuerySnapshot roomsSnapshot =
          await FirebaseFirestore.instance.collection('rooms').get();
      print("print 2");

      for (var roomDoc in roomsSnapshot.docs) {
        print("print 3");
        Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;
        print("print 4");

        try {
          // Fetch the last message for this room
          QuerySnapshot messagesSnapshot = await roomDoc.reference
              .collection('messages')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();
          print("print 5");

          if (messagesSnapshot.docs.isNotEmpty) {
            final messageDoc = messagesSnapshot.docs.first;
            final message = messageDoc['message'];
            final recieverName = messageDoc['receiverName'];
            final senderName = messageDoc['senderName'];
            final createdAt = messageDoc['timestamp'];
            final receiverImage = messageDoc['recieverImage'];
            final senderImage = messageDoc['senderImage'];
            final receiver = messageDoc['receiver'];
            final sender = messageDoc['sender'];

            if (sender == "+91" + currentUserId ||
                receiver == "+91" + currentUserId) {
              roomData['message'] = message != null ? message : '';
              roomData['timestamp'] = createdAt != null ? createdAt : '';
              roomData['receiverName'] =
                  recieverName != null ? recieverName : '';
              roomData['senderName'] = senderName != null ? senderName : '';
              roomData['receiver'] = receiver != null ? receiver : '';
              roomData['receiverImage'] =
                  receiverImage != null ? receiverImage : '';
              roomData['senderImage'] = senderImage != null ? senderImage : '';
              roomData['sender'] = sender != null ? sender : '';
              roomData['currentUserId'] =
                  "+91" + currentUserId != null ? "+91" + currentUserId : "";
              chatRooms.add(roomData);
            }
          } else {
            print("rooms empty: " + messagesSnapshot.docs.length.toString());
          }
        } catch (e) {
          print("Error fetching messages for room ${roomDoc.id}: $e");
        }
      }
    } catch (e) {
      print("Error fetching rooms: $e");
    }

    return chatRooms;
  }

  void testFirestoreAccess() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('rooms')
          .doc('+917200645321-8072974576')
          .get();
      if (doc.exists) {
        print('Test document data: ${doc.data().toString()}');
      } else {
        print('Test document does not exist');
      }
    } catch (e) {
      print('Error reading test document: $e');
    }
  }
}
