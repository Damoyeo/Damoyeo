import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String title;
  final String content;
  final String author;
  final DateTime createdAt;

  Post({
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
  });

  // Firestore 데이터를 Post 객체로 변환
  factory Post.fromFirestore(Map<String, dynamic> data) {
    return Post(
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      author: data['author'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
