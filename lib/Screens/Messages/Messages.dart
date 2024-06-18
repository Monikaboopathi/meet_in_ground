import 'package:flutter/material.dart';
import 'package:meet_in_ground/Screens/Messages/MessageSearch.dart';
import 'package:meet_in_ground/Screens/chat/ChatScreen.dart';
import 'package:meet_in_ground/constant/format_time.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/util/Services/ChatService.dart';
import 'package:meet_in_ground/widgets/BottomNavigationScreen.dart';
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

  Future<void> _refreshChatRooms() async {
    setState(() {
      _futureChatRooms = _chatservice.getAllMessagesAndRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.background,
      appBar: AppBar(
        notificationPredicate: (notification) => false,
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: ThemeService.textColor,
            ),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ChatSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BottomNavigationScreen(currentIndex: 0),
            ),
          );
          return false;
        },
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureChatRooms,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Loader();
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return NoDataFoundWidget(errorText: "No Messages yet",);
            }

            List<Map<String, dynamic>> chatRooms = snapshot.data!;
            chatRooms.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
            return RefreshIndicator(
              onRefresh: _refreshChatRooms,
              child: ListView.builder(
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
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          chatRoom['timestamp'] != null
                              ? formatDateTime(chatRoom['timestamp'])
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
                    leading: Stack(
                      children: [
                        Container(
                          width: 50.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ThemeService.primary,
                              width: 1.0,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                              chatRoom['sender'] == chatRoom['currentUserId']
                                  ? chatRoom['receiverImage']
                                  : chatRoom['senderImage'],
                            ),
                            backgroundColor: ThemeService.textColor,
                            foregroundColor: ThemeService.textColor,
                          ),
                        ),
                        if (chatRoom['receiver'] == chatRoom['currentUserId'] &&
                            !chatRoom['isRead'])
                          Positioned(
                            right: 5,
                            top: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
