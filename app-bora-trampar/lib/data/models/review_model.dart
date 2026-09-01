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
}
