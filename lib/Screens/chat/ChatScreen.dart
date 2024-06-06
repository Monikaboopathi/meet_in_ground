import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:intl/intl.dart';
import 'package:meet_in_ground/Models/Message.dart';
import 'package:meet_in_ground/constant/format_time.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/util/Services/ChatService.dart';
import 'package:meet_in_ground/util/Services/mobileNo_service.dart';
import 'package:meet_in_ground/widgets/BottomNavigationScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meet_in_ground/widgets/Loader.dart';

class ChatScreen extends StatefulWidget {
  final String recieverName;
  final String recieverImage;
  final String receiverId;

  ChatScreen({
    Key? key,
    required this.recieverName,
    required this.recieverImage,
    required this.receiverId,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  ScrollController _emojiScroll = ScrollController();
  ScrollController _messageScroll = ScrollController();
  bool showEmojiPicker = false;
  final Chatservice _chatservice = Chatservice();
  String? currentMobileNumber;

  Map<int, bool> isMessageExpanded = {};

  @override
  void initState() {
    super.initState();
    initializeData().then((mobileNumber) {
      if (mounted) {
        setState(() {
          currentMobileNumber = mobileNumber!;
        });
      }
    });
  }

  Future<String?> initializeData() async {
    try {
      String? number = await MobileNo.getMobilenumber();
      return number;
    } catch (exception) {
      print(exception);
    }
    return null;
  }

  void onSendMessage() async {
    if (messageController.text.isNotEmpty) {
      await _chatservice.sendMessage(widget.receiverId, messageController.text,
          widget.recieverName, widget.recieverImage);
      messageController.clear();
      scrollToBottom(); // Scroll to bottom after sending a message
    } else {
      print("Enter Some Text");
    }
  }

  void scrollToBottom() {
    if (_messageScroll.hasClients) {
      _messageScroll.jumpTo(_messageScroll.position.maxScrollExtent);
    }
  }

  String getMessageDate(DateTime timestamp) {
    DateTime messageDate = timestamp;
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(Duration(days: 1));

    if (messageDate.isAfter(today)) {
      return 'Today';
    } else if (messageDate.isAfter(yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('dd MMM yyyy').format(messageDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.background,
      appBar: AppBar(
        notificationPredicate: (notification) => false,
        backgroundColor: ThemeService.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeService.textColor, size: 35),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BottomNavigationScreen(currentIndex: 1),
            ),
          ),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ThemeService.textColor, // Border color
                  width: 2.0, // Border width
                ),
              ),
              child: CircleAvatar(
                backgroundImage: NetworkImage(widget.recieverImage),
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.recieverName,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ThemeService.textColor),
                ),
                // Text(
                //   'Online',
                //   style:
                //       TextStyle(fontSize: 12, color: ThemeService.placeHolder),
                // ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _chatservice.getMessages(widget.receiverId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Loader();
                  }

                  var messages = snapshot.data!.docs.map((doc) {
                    return Message.fromMap(doc.data() as Map<String, dynamic>);
                  }).toList();

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    scrollToBottom();
                  });

                  DateTime? lastDisplayedDate;

                  return ListView.builder(
                    controller: _messageScroll,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isSender =
                          message.sender == "+91" + currentMobileNumber!;
                      final isMessageTruncated = message.message.length > 100;
                      final isExpanded = isMessageExpanded.containsKey(index)
                          ? isMessageExpanded[index]!
                          : false;
                      final messageDate = message.timestamp.toDate();
                      bool showDate = false;

                      if (lastDisplayedDate == null ||
                          messageDate.day != lastDisplayedDate!.day ||
                          messageDate.month != lastDisplayedDate!.month ||
                          messageDate.year != lastDisplayedDate!.year) {
                        showDate = true;
                        lastDisplayedDate = messageDate;
                      }

                      return Column(
                        children: [
                          if (showDate)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: ThemeService.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    getMessageDate(messageDate),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: ThemeService.textColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Row(
                            mainAxisAlignment: isSender
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(width: 10),
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isMessageExpanded[index] =
                                          !(isMessageExpanded[index] ?? false);
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSender
                                          ? Colors.green[100]
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.only(
                                        topLeft: isSender
                                            ? Radius.circular(16)
                                            : Radius.circular(0),
                                        topRight: isSender
                                            ? Radius.circular(0)
                                            : Radius.circular(16),
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: IntrinsicWidth(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Text(
                                              isExpanded
                                                  ? message.message
                                                  : (isMessageTruncated
                                                      ? '${message.message.substring(0, 100)}...'
                                                      : message.message),
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  right: 12,
                                                  bottom: 4,
                                                  left: 12),
                                              child: Text(
                                                formatTime(message.timestamp),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (isMessageTruncated)
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  isMessageExpanded[index] =
                                                      !(isMessageExpanded[
                                                              index] ??
                                                          false);
                                                });
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 12, bottom: 8),
                                                child: Text(
                                                  isExpanded
                                                      ? 'Show less'
                                                      : 'Show more',
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                          SizedBox(height: 20),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: ThemeService.primary,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          showEmojiPicker = !showEmojiPicker;
                        });
                      },
                      icon: Icon(
                        Icons.emoji_emotions,
                        color: ThemeService.textColor,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration.collapsed(
                            hintText: 'Type a message...',
                            hintStyle:
                                TextStyle(color: ThemeService.placeHolder),
                          ),
                          textInputAction: TextInputAction.send,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          autocorrect: true,
                          cursorColor: ThemeService.primary,
                          style: TextStyle(color: ThemeService.textColor),
                          onChanged: (value) => setState(() {
                            messageController.text = value;
                          }),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onSendMessage,
                      icon: Icon(Icons.send, color: ThemeService.primary),
                    ),
                  ],
                ),
              ),
            ),
            if (showEmojiPicker)
              Expanded(
                child: EmojiPicker(
                  textEditingController: messageController,
                  scrollController: _emojiScroll,
                  config: Config(
                    height: 256,
                    checkPlatformCompatibility: true,
                    emojiViewConfig: EmojiViewConfig(
                      emojiSizeMax: 28 *
                          (foundation.defaultTargetPlatform ==
                                  TargetPlatform.iOS
                              ? 1.2
                              : 1.0),
                    ),
                    swapCategoryAndBottomBar: false,
                    skinToneConfig: const SkinToneConfig(),
                    categoryViewConfig: const CategoryViewConfig(),
                    bottomActionBarConfig: const BottomActionBarConfig(),
                    searchViewConfig: const SearchViewConfig(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
