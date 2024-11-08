import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gomoph/post/create_post.dart';
import 'package:gomoph/post/post_detail.dart';
import '../../models/post.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostListPage extends StatefulWidget {
  const PostListPage({super.key});

  @override
  _PostListPageState createState() => _PostListPageState();
}

// 게시물 리스트 페이지
class _PostListPageState extends State<PostListPage> {
  String _sortOption = '최신순'; // 기본 정렬 기준은 최신순

  // Firestore에서 'posts' 컬렉션의 데이터를 스트림 형태로 가져오는 변수
  Stream<QuerySnapshot<Post>> getPostsStream() {
    Query<Post> query =
        FirebaseFirestore.instance.collection('posts').withConverter<Post>(
              fromFirestore: (snapshot, _) => Post.fromJson(snapshot.data()!),
              toFirestore: (post, _) => post.toJson(),
            );

    // 선택한 정렬 옵션에 따라 쿼리를 설정
    if (_sortOption == '최신순') {
      query = query.orderBy('createdAt', descending: true);
    } else if (_sortOption == '오래된순') {
      query = query.orderBy('createdAt', descending: false);
    } else if (_sortOption == '가나다순') {
      query = query.orderBy('title', descending: false);
    } else if (_sortOption == '가나다 역순') {
      query = query.orderBy('title', descending: true);
    }

    return query.snapshots();
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
              // 최신순과 오래된순 옵션
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
              // 가나다순과 가나다 역순 옵션
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Colors.white, //배경색 고정
        centerTitle: true,
        title: Row(
          children: [
            SizedBox(width: 8.0), // 좌측 여백
            // Sort 버튼
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(20), // 둥근 모서리 테두리
              ),
              child: TextButton.icon(
                onPressed: () => _showSortOptions(context),
                // Sort 모달 창 표시
                icon: Icon(Icons.unfold_more, color: Colors.blue),
                // 위아래 화살표 아이콘
                label: Text(
                  'Sort',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
            Spacer(),
            Text(
              '모집 게시물',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            // Filter 버튼
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(20), // 둥근 모서리 테두리
              ),
              child: TextButton.icon(
                onPressed: () => _showFilterOptions(context),
                icon: Icon(Icons.filter_list, color: Colors.blue),
                label: Text('Filter', style: TextStyle(color: Colors.blue)),
              ),
            ),
            SizedBox(width: 8.0), // 우측 여백
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Post>>(
        stream: getPostsStream(), // 선택한 정렬 기준에 따라 데이터 스트림 설정
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Firestore 연결 오류 발생'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('게시물이 없습니다.'));
          }
          final posts = snapshot.data!.docs.map((doc) => doc.data()).toList();

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final userId = getCurrentUserId();

              return Card(

                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                      Text(post.content.length > 15
                          ? '${post.content.substring(0, 15)}...'
                          : post.content),
                      // 15글자까지만 표시하고 나머지는 생략
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
      //글쓰기 플로팅버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePost()),
          );
        },
        child: Icon(Icons.edit),
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
}
