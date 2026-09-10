class ReviewModel {
  final String id;
  final String authorName;
  final String? authorAvatar;
  final double rating;
  final String timeAgo;
  final String comment;

  const ReviewModel({
    required this.id,
    required this.authorName,
    this.authorAvatar,
    required this.rating,
    required this.timeAgo,
    required this.comment,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      authorName: json['authorName'],
      rating: json['rating'],
      timeAgo: json['timeAgo'],
      comment: json['comment'],
    );
  }
}
