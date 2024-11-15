import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/post.dart';
import '../../post/post_detail.dart';

class MyActivityPage extends StatefulWidget {
  const MyActivityPage({Key? key}) : super(key: key);

  @override
  _MyActivityPageState createState() => _MyActivityPageState();
}

class _MyActivityPageState extends State<MyActivityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Stream<List<Post>> getMyPostsStream() {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Post.fromJson(doc.data())).toList();
    });
  }

  Stream<List<Post>> getParticipatedPostsStream() {
    return FirebaseFirestore.instance
        .collection('posts')
        .snapshots()
        .asyncMap((snapshot) async {
      final participatedPosts = <Post>[];
      for (final doc in snapshot.docs) {
        final proposerDoc =
        await doc.reference.collection('proposers').doc(userId).get();
        if (proposerDoc.exists) {
          participatedPosts.add(Post.fromJson(doc.data()));
        }
      }
      return participatedPosts;
    });
  }

  Future<bool> _isLiked(String postId) async {
    final favoriteRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('favorite')
        .doc(userId);
    final docSnapshot = await favoriteRef.get();
    return docSnapshot.exists;
  }

  Future<void> _toggleFavorite(String postId) async {
    final favoriteRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('favorite')
        .doc(userId);
    final isLiked = await _isLiked(postId);

    if (isLiked) {
      await favoriteRef.delete();
    } else {
      await favoriteRef.set({
        'user_id': userId,
        'createdAt': Timestamp.now(),
      });
    }
    setState(() {}); // 좋아요 상태 갱신
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "활동 내역",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Colors.blue,
          tabs: [
            Tab(text: "내 모집"),
            Tab(text: "참가한 모집"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 내 모집 탭
          StreamBuilder<List<Post>>(
            stream: getMyPostsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("오류가 발생했습니다."));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              final posts = snapshot.data;
              if (posts == null || posts.isEmpty) {
                return Center(child: Text("작성한 모집글이 없습니다."));
              }
              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return PostCard(
                    post: post,
                    isFavorite: true, // 내가 작성한 글이므로 찜 상태는 true
                    onFavoriteToggle: () => _toggleFavorite(post.id),
                  );
                },
              );
            },
          ),
          // 참가한 모집 탭
          StreamBuilder<List<Post>>(
            stream: getParticipatedPostsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("오류가 발생했습니다."));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              final posts = snapshot.data;
              if (posts == null || posts.isEmpty) {
                return Center(child: Text("참가한 모집글이 없습니다."));
              }
              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return FutureBuilder<bool>(
                    future: _isLiked(post.id),
                    builder: (context, snapshot) {
                      bool isFavorite = snapshot.data ?? false;
                      return PostCard(
                        post: post,
                        isFavorite: isFavorite,
                        onFavoriteToggle: () => _toggleFavorite(post.id),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// 게시물 카드 위젯
class PostCard extends StatelessWidget {
  final Post post;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const PostCard({
    Key? key,
    required this.post,
    required this.isFavorite,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Container(
          width: 50.0,
          height: 50.0,
          color: Colors.grey[300],
          child: post.imageUrl.isNotEmpty
              ? Image.network(post.imageUrl, fit: BoxFit.cover)
              : Icon(Icons.image, color: Colors.white),
        ),
        title: Text(post.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.content),
            Text('참여인원 ${post.recruit}/6'),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.grey,
          ),
          onPressed: onFavoriteToggle,
        ),
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
  }
}
