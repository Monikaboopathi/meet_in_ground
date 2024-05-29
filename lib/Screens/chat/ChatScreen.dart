import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/widgets/BottomNavigationScreen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  ScrollController _emojiScroll = ScrollController();
  bool showEmojiPicker = false;

  // Track whether each message is expanded or not
  Map<int, bool> isMessageExpanded = {};

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
              backgroundImage: AssetImage('assets/galleryImage.png'),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Name',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // IconButton(
          //   onPressed: () {},
          //   icon: Icon(Icons.videocam),
          // ),
          // IconButton(
          //   onPressed: () {},
          //   icon: Icon(Icons.call),
          // ),
          // IconButton(
          //   onPressed: () {},
          //   icon: Icon(Icons.more_vert),
          // ),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context)
            .size
            .width, // Set width of the container to full screen width
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8),
                itemCount: 20,
                itemBuilder: (context, index) {
                  final isSender = index.isOdd;

                  // Generate dummy message with emojis
                  final message = isSender
                      ? 'To add user icons and names like the WhatsApp UI, you can modify the ListView.builder to include user information for each message. Here'
                      : 'Reply 👍';

                  // Truncate message if it exceeds a certain length
                  final isMessageTruncated = message.length > 100;

                  // Check if message is expanded or not
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
                                width: MediaQuery.of(context).size.width *
                                    0.7, // Set maximum width for the message
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Text(
                                        isExpanded
                                            ? message
                                            : (isMessageTruncated
                                                ? '${message.substring(0, 100)}...'
                                                : message),
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
                                          '10:00 AM',
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
                                                !(isMessageExpanded[index] ??
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey, // Specify the border color here
                    width: 1.0, // Specify the border width here
                  ),
                  borderRadius: BorderRadius.circular(
                      24.0), // Specify the border radius here
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          showEmojiPicker = !showEmojiPicker;
                          print('Emoji Picker Visibility: $showEmojiPicker');
                        });
                      },
                      icon: Icon(Icons.emoji_emotions),
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration.collapsed(
                            hintText: 'Type a message...',
                          ),
                          textInputAction: TextInputAction.send,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          autocorrect: true,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Implement send message functionality
                      },
                      icon: Icon(Icons.send),
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
