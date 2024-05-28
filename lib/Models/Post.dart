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
  final String? createdAt;

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
    this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'],
      image: json['image'],
      userName: json['userName'],
      phoneNumber: json['phoneNumber'],
      sport: json['sport'],
      matchDetails: json['matchDetails'],
      matchDate: json['matchDate'],
      betAmount: json['betAmount'],
      placeOfMatch: json['placeOfMatch'],
      status: json['status'],
      postOwnerImage: json['postOwnerImage'],
      likes: json['favorites'].length,
      comments: json['requests'].length,
      favorites: json['favorites'],
      requests: json['requests'],
      createdAt: json['createdAt'],
    );
  }
}
