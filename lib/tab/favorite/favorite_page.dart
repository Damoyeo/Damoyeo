import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gomoph/post/post_detail.dart';
import '../../models/post.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  String _sortOption = '최신순'; // 기본 정렬 기준

  // Firestore에서 현재 사용자가 찜한 게시물만 가져오는 스트림
  Stream<List<Post>> getFavoritePostsStream() async* {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      yield []; // 로그인된 사용자가 없을 경우 빈 리스트 반환
    } else {
      // 모든 posts 컬렉션 문서를 가져옴
      final postsSnapshot = await FirebaseFirestore.instance.collection('posts').get();

      final favoritePosts = <Post>[];
      for (final postDoc in postsSnapshot.docs) {
        // 각 게시물의 favorite 하위 컬렉션에 userId 문서가 있는지 확인
        final favoriteDoc = await postDoc.reference.collection('favorite').doc(userId).get();
        if (favoriteDoc.exists) {
          favoritePosts.add(Post.fromJson(postDoc.data()));
        }
      }

      // 선택한 정렬 옵션에 따라 리스트 정렬
      if (_sortOption == '최신순') {
        favoritePosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else if (_sortOption == '오래된순') {
        favoritePosts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      } else if (_sortOption == '가나다순') {
        favoritePosts.sort((a, b) => a.title.compareTo(b.title));
      } else if (_sortOption == '가나다 역순') {
        favoritePosts.sort((a, b) => b.title.compareTo(a.title));
      }

      yield favoritePosts;
    }
  }

  // 정렬 모달 시트를 표시하는 함수
  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _sortOption = _sortOption == '최신순' ? '오래된순' : '최신순';
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      _sortOption == '최신순' ? '오래된순' : '최신순',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _sortOption = _sortOption == '가나다순' ? '가나다 역순' : '가나다순';
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      _sortOption == '가나다순' ? '가나다 역순' : '가나다순',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 필터 모달 시트를 표시하는 함수
  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Option 1'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Option 2'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Row(
          children: [
            SizedBox(width: 8.0),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextButton.icon(
                onPressed: () => _showSortOptions(context),
                icon: Icon(Icons.unfold_more, color: Colors.blue),
                label: Text('Sort', style: TextStyle(color: Colors.blue)),
              ),
            ),
            Spacer(),
            Text(
              "찜한 게시물",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextButton.icon(
                onPressed: () => _showFilterOptions(context),
                icon: Icon(Icons.filter_list, color: Colors.blue),
                label: Text('Filter', style: TextStyle(color: Colors.blue)),
              ),
            ),
            SizedBox(width: 8.0),
          ],
        ),
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
              final userId = getCurrentUserId();

              return Card(
                margin: EdgeInsets.only(bottom: 8),
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
                      Text(
                        post.content.length > 15
                            ? '${post.content.substring(0, 15)}...'
                            : post.content,
                      ),
                      Text('지역: ${post.tag}'),
                      Text('모집인원 ${post.recruit}'),
                    ],
                  ),
                    trailing: FutureBuilder<bool>(
                      future: userId != null
                          ? _isLiked(post.id, userId!)
                          : Future.value(false),
                      builder: (context, snapshot) {
                        bool isLiked = snapshot.data ?? false;
                        return IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : null,
                          ),
                          onPressed: () {
                            if (userId != null) {
                              _toggleFavorite(post.id, userId!);
                            } else {
                              print("User not logged in");
                            }
                          },
                        );
                      },
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
            },
          );
        },
      ),
    );
  }

  // 사용자 ID 가져오기
  String? getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Future<bool> _isLiked(String postId, String userId) async {
    final favoriteRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('favorite')
        .doc(userId);
    final docSnapshot = await favoriteRef.get();
    return docSnapshot.exists;
  }

  Future<void> _toggleFavorite(String postId, String userId) async {
    final favoriteRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('favorite')
        .doc(userId);
    final isLiked = await _isLiked(postId, userId);

    if (isLiked) {
      await favoriteRef.delete();
    } else {
      await favoriteRef.set({
        'user_id': userId,
        'createdAt': Timestamp.now(),
      });
    }
    setState(() {});
  }
}
