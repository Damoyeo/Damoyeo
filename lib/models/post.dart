import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Post {
  String id;
  String title;
  String content;
  String tag;
  int recruit;
  DateTime createdAt;
  String imageUrl;// 이미지 URL 필드 추가 (nullable)
  List<String> imageUrls;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.tag,
    required this.createdAt,
    required this.recruit,
    required this.imageUrl,
    required this.imageUrls, // 생성자에 imageUrl 추가
  });

  // Firestore 데이터를 Post 객체로 변환
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      tag: json['tag'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      recruit: json['recruit'] as int,
      imageUrl: json['imageUrl'] as String,
      imageUrls: List<String>.from(json['imageUrls'] ?? []), // 안전하게 리스트 변환
    );
  }

  // Post 객체를 JSON 형식으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tag': tag,
      'createdAt': Timestamp.fromDate(createdAt),
      'recruit': recruit,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls// imageUrl 필드 추가
    };
  }
}
