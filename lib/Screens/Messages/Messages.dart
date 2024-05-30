import 'package:flutter/material.dart';
import 'package:meet_in_ground/Models/Message.dart';
import 'package:meet_in_ground/Screens/chat/ChatScreen.dart';
import 'package:meet_in_ground/constant/format_time.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/util/Services/ChatService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meet_in_ground/widgets/Loader.dart';

class Messages extends StatelessWidget {
  Messages({Key? key}) : super(key: key);
  final Chatservice _chatservice = Chatservice();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.background,
      appBar: AppBar(
        backgroundColor: ThemeService.background,
        title: Text(
          'Messages',
          style: TextStyle(
            color: ThemeService.textColor,
            fontFamily: 'Billabong',
            fontSize: 25,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _chatservice.getMessages("8072974576", "8072974576"),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Loader();
          }

          var chatRooms = snapshot.data!.docs.map((doc) {
            return Message.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();
          print(chatRooms);
          return ListView.builder(
            itemCount: 1,
            itemBuilder: (context, index) {
              var chatRoom = chatRooms[chatRooms.length - 1];

              return ListTile(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        recieverName: chatRoom.sender,
                        recieverImage: chatRoom.message,
                      ),
                    ),
                  );
                },
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      chatRoom.receiver,
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeService.textColor,
                      ),
                    ),
                    Text(
                      formatDate(chatRoom
                          .timestamp), 
                      style: TextStyle(
                        fontSize: 13,
                        color: ThemeService.placeHolder,
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    chatRoom
                        .message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: ThemeService.placeHolder),
                  ),
                ),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(chatRoom.receiver),
                  backgroundColor: Colors.grey[300],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
