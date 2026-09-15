class ReviewModel {
  final String id;
  final String authorName;
  final String? authorAvatar;
  final double rating;
  final double point;
  final String timeAgo;
  final String comment;

  const ReviewModel({
    required this.id,
    required this.authorName,
    this.authorAvatar,
    required this.rating,
    required this.point,
    required this.timeAgo,
    required this.comment,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json.containsKey("id") ? json['id'] : "",
      authorName: json.containsKey("authorName") ? json['authorName'] : "",
      rating: json.containsKey("rating") ? double.parse(json['rating'].toString()) : 0,
      point: json.containsKey("point") ? double.parse(json['point'].toString()) : 0,
      timeAgo: json.containsKey("timeAgo") ? json['timeAgo'] : "",
      comment: json.containsKey("comment") ? json['comment'] : "",
    );
  }
}
