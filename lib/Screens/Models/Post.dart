// models/post.dart
class Post {
  final String id;
  final String image;
  final String userName;
  final String phoneNumber;
  final String sport;
  final String matchDetails;
  final String matchDate;
  final int betAmount;
  final String placeOfMatch;
  final String status;
  final String postOwnerImage;
  final int likes;
  final int comments;
  final List<dynamic> favorites;
  final List<dynamic> requests;

  Post({
    required this.id,
    required this.image,
    required this.userName,
    required this.phoneNumber,
    required this.sport,
    required this.matchDetails,
    required this.matchDate,
    required this.betAmount,
    required this.placeOfMatch,
    required this.status,
    required this.postOwnerImage,
    required this.likes,
    required this.comments,
    required this.favorites,
    required this.requests,
  });
}
