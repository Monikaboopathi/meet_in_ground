
import 'package:meet_in_ground/Models/Post.dart';
import 'package:share_plus/share_plus.dart';

Future<void> shareMessage(String message) async {
  try {
    await Share.share(message);
  } catch (error) {
    print(error);
  }
}

String getPlayStoreUrl() {
  return "https://play.google.com/store/apps/details?id=your.app.package";
}

String getAppShareMessage() {
  String playStoreUrl = getPlayStoreUrl();
  return "Check out this amazing app! Download it from the app store:\n$playStoreUrl";
}

String getPostShareMessage(Post post) {
  String playStoreUrl = getPlayStoreUrl();
  return "Check out this post by ${post.userName}:\n\n" +
      "📝 Description: ${post.matchDetails}\n\n" +
      "📅 Date: ${post.matchDate}\n\n" +
      "📍 Location: ${post.placeOfMatch}\n\n" +
      "💰 Price: ${post.betAmount}\n\n" +
      "⚽ Sport: ${post.sport}\n\n" +
      "📱 Play Store URL: $playStoreUrl";
}

void shareApp() async {
  String message = getAppShareMessage();
  await shareMessage(message);
}

void sharePost(Post post) async {
  String message = getPostShareMessage(post);
  await shareMessage(message);
}
