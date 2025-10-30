import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  final String id;
  final String userId;
  final String userName;
  final int rating; // 1-5 stars
  final DateTime timestamp;

  Rating({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.timestamp,
  });

  factory Rating.fromMap(String id, Map<String, dynamic> data) {
    final raw = data['timestamp'];
    final dt = raw is Timestamp ? raw.toDate() : DateTime.parse(raw as String);
    return Rating(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      rating: data['rating'] ?? 0,
      timestamp: dt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
