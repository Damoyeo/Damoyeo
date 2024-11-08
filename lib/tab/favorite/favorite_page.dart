import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/post.dart';
import '../../post/post_detail.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  // 현재 사용자의 찜한 게시물만 가져오는 스트림
  Stream<List<Post>> getFavoritePostsStream() {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      // 로그인된 사용자가 없을 경우 빈 스트림 반환
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('posts')
        .where('favorite.$userId', isEqualTo: true) // 현재 사용자가 좋아요한 게시물 필터링
        .withConverter<Post>(
      fromFirestore: (snapshot, _) => Post.fromJson(snapshot.data()!),
      toFirestore: (post, _) => post.toJson(),
    )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("찜 목록"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<List<Post>>(
        stream: getFavoritePostsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final posts = snapshot.data;
          if (posts == null || posts.isEmpty) {
            return Center(child: Text('찜한 게시물이 없습니다.'));
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 50.0,
                    height: 50.0,
                    color: Colors.grey[300],
                    child: post.imageUrl != null
                        ? Image.network(post.imageUrl!, fit: BoxFit.cover)
                        : Icon(Icons.image, color: Colors.white),
                  ),
                  title: Text(post.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.content.length > 15
                            ? '${post.content.substring(0, 15)}...'
                            : post.content,
                      ),
                      Text('지역: ${post.tag}'),
                      Text('모집인원 ${post.recruit}'),
                    ],
                  ),
                  trailing: Icon(Icons.favorite, color: Colors.blue),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetail(post: post),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
