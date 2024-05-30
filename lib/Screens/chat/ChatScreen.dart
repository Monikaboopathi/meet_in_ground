import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:meet_in_ground/Models/Message.dart';
import 'package:meet_in_ground/constant/format_time.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/util/Services/ChatService.dart';
import 'package:meet_in_ground/widgets/BottomNavigationScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meet_in_ground/widgets/Loader.dart';

class ChatScreen extends StatefulWidget {
  String recieverName;
  String recieverImage;
  ChatScreen(
      {Key? key, required this.recieverName, required this.recieverImage})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  ScrollController _emojiScroll = ScrollController();
  bool showEmojiPicker = false;
  final Chatservice _chatservice = Chatservice();

  Map<int, bool> isMessageExpanded = {};

  void onSendMessage() async {
    if (messageController.text.isNotEmpty) {
      await _chatservice.sendMessage("8072974576", messageController.text);
      messageController.clear();
    } else {
      print("Enter Some Text");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.background,
      appBar: AppBar(
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
            CircleAvatar(
              backgroundImage: NetworkImage(widget.recieverImage),
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
                Text(
                  'Online',
                  style:
                      TextStyle(fontSize: 12, color: ThemeService.placeHolder),
                ),
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
                stream: _chatservice.getMessages("8072974576", "8072974576"),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Loader();
                  }

                  var messages = snapshot.data!.docs.map((doc) {
                    return Message.fromMap(doc.data() as Map<String, dynamic>);
                  }).toList();

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isSender = message.sender == "8072974576";
                      final isMessageTruncated = message.message.length > 100;
                      final isExpanded = isMessageExpanded.containsKey(index)
                          ? isMessageExpanded[index]!
                          : false;

                      return Column(
                        children: [
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
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
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
                                                right: 12, bottom: 4),
                                            child: Text(
                                              formatDate(message.timestamp),
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
