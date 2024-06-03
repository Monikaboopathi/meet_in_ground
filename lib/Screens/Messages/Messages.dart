import 'package:flutter/material.dart';

import 'package:meet_in_ground/Screens/chat/ChatScreen.dart';
import 'package:meet_in_ground/constant/format_time.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/util/Services/ChatService.dart';

import 'package:meet_in_ground/widgets/Loader.dart';
import 'package:meet_in_ground/widgets/NoDataFoundWidget.dart';

class Messages extends StatefulWidget {
  Messages({Key? key}) : super(key: key);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final Chatservice _chatservice = Chatservice();
  late Future<List<Map<String, dynamic>>> _futureChatRooms;

  @override
  void initState() {
    super.initState();
    _futureChatRooms = _chatservice.getAllMessagesAndRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.background,
      appBar: AppBar(
        backgroundColor: ThemeService.background,
        automaticallyImplyLeading: false,
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureChatRooms,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loader();
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return NoDataFoundWidget();
          }

          List<Map<String, dynamic>> chatRooms = snapshot.data!;
          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              var chatRoom = chatRooms[index];

              return ListTile(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        recieverName:
                            chatRoom['sender'] == chatRoom['currentUserId']
                                ? chatRoom['receiverName']
                                : chatRoom['senderName'],
                        recieverImage:
                            chatRoom['sender'] == chatRoom['currentUserId']
                                ? chatRoom['receiverImage']
                                : chatRoom['senderImage'],
                        receiverId:
                            chatRoom['sender'] == chatRoom['currentUserId']
                                ? chatRoom['receiver']
                                : chatRoom['sender'],
                      ),
                    ),
                  );
                },
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      chatRoom['sender'] == chatRoom['currentUserId']
                          ? chatRoom['receiverName']
                          : chatRoom['senderName'],
                      style: TextStyle(
                        fontSize: 15,
                        color: ThemeService.textColor,
                      ),
                    ),
                    Text(
                      chatRoom['timestamp'] != null
                          ? formatDate(chatRoom['timestamp'])
                          : "",
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
                    chatRoom['message'] ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: ThemeService.placeHolder),
                  ),
                ),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                      chatRoom['sender'] == chatRoom['currentUserId']
                          ? chatRoom['receiverImage']
                          : chatRoom['senderImage']),
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
