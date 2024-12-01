import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Post {
  String documentId; // Firestore 문서 ID
  String id;
  String title;
  String content;
  String tag;
  int recruit;
  DateTime createdAt;
  String imageUrl;// 이미지 URL 필드 추가 (nullable)
  List<String> imageUrls;
  String address;
  String detailAddress;
  String category;
  int cost;
  DateTime meetingTime;

  Post({
    required this.documentId, // Firestore 문서 ID
    required this.id,
    required this.title,
    required this.content,
    required this.tag,
    required this.createdAt,
    required this.recruit,
    required this.imageUrl,
    required this.imageUrls, // 생성자에 imageUrl 추가
    required this.address,
    required this.detailAddress,
    required this.category,
    required this.cost,
    required this.meetingTime,
  });

  // Firestore 데이터를 Post 객체로 변환
  factory Post.fromJson(Map<String, dynamic> json, String documentId) {
    return Post(
      documentId: documentId, // Firestore 문서 ID
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      tag: json['tag'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      recruit: json['recruit'] as int,
      imageUrl: json['imageUrl'] as String,
      imageUrls: List<String>.from(json['imageUrls'] ?? []), // 안전하게 리스트 변환
      address: json['address'] as String? ?? 'Unknown address', // 기본값 설정
      detailAddress: json['detailAddress'] as String? ?? 'Unknown detail address', // 기본값 설정
      category: json['category'] as String? ?? 'General', // 기본값 설정
      cost: json['cost'] as int? ?? 0, // 기본값 설정
      meetingTime: (json['meetingTime'] as Timestamp?)?.toDate() ?? DateTime.now(), // null 체크 및 기본값 설정
    );
  }

  // Post 객체를 JSON 형식으로 변환
  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'id': id,
      'title': title,
      'content': content,
      'tag': tag,
      'createdAt': Timestamp.fromDate(createdAt),
      'recruit': recruit,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,// imageUrl 필드 추가
      'address': address,
      'detailAddress': detailAddress,
      'category': category,
      'cost': cost,
      'meetingTime' : Timestamp.fromDate(meetingTime),
    };
  }
}
