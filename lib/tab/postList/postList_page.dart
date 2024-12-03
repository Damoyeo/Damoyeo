import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gomoph/post/create_post.dart';
import 'package:gomoph/post/post_detail.dart';
import '../../models/post.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostListPage extends StatefulWidget {
  const PostListPage({Key? key}) : super(key: key);

  @override
  _PostListPageState createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  String _sortOption = '최신순'; // 기본 정렬 기준은 최신순
  String _filterOption = '전체보기'; // 기본 필터 옵션

  Stream<QuerySnapshot<Post>> getPostsStream() {
    Query<Post> query =
    FirebaseFirestore.instance.collection('posts').withConverter<Post>(
      fromFirestore: (snapshot, _) =>
          Post.fromJson(snapshot.data()!, snapshot.id),
      toFirestore: (post, _) => post.toJson(),
    );

    if (_filterOption != '전체보기') {
      query = query.where('category', isEqualTo: _filterOption); // 선택된 필터 적용
    }

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
                        _sortOption =
                        _sortOption == '최신순' ? '오래된순' : '최신순';
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
                        _sortOption =
                        _sortOption == '가나다순' ? '가나다 역순' : '가나다순';
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

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              FilterButton(
                label: '전체보기',
                onTap: () {
                  setState(() {
                    _filterOption = '전체보기';
                  });
                  Navigator.pop(context);
                },
              ),
              FilterButton(
                label: '친목',
                onTap: () {
                  setState(() {
                    _filterOption = '친목';
                  });
                  Navigator.pop(context);
                },
              ),
              FilterButton(
                label: '스포츠',
                onTap: () {
                  setState(() {
                    _filterOption = '스포츠';
                  });
                  Navigator.pop(context);
                },
              ),
              FilterButton(
                label: '스터디',
                onTap: () {
                  setState(() {
                    _filterOption = '스터디';
                  });
                  Navigator.pop(context);
                },
              ),
              FilterButton(
                label: '여행',
                onTap: () {
                  setState(() {
                    _filterOption = '여행';
                  });
                  Navigator.pop(context);
                },
              ),
              FilterButton(
                label: '알바',
                onTap: () {
                  setState(() {
                    _filterOption = '알바';
                  });
                  Navigator.pop(context);
                },
              ),
              FilterButton(
                label: '게임',
                onTap: () {
                  setState(() {
                    _filterOption = '게임';
                  });
                  Navigator.pop(context);
                },
              ),
              FilterButton(
                label: '봉사',
                onTap: () {
                  setState(() {
                    _filterOption = '봉사';
                  });
                  Navigator.pop(context);
                },
              ),
              FilterButton(
                label: '헬스',
                onTap: () {
                  setState(() {
                    _filterOption = '헬스';
                  });
                  Navigator.pop(context);
                },
              ),
              FilterButton(
                label: '음악',
                onTap: () {
                  setState(() {
                    _filterOption = '음악';
                  });
                  Navigator.pop(context);
                },
              ),
              FilterButton(
                label: '기타',
                onTap: () {
                  setState(() {
                    _filterOption = '기타';
                  });
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
              '모집 게시물',
              style:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
      ),
      body: StreamBuilder<QuerySnapshot<Post>>(
        stream: getPostsStream(),
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
                    width: 90.0,
                    height: 250.0,
                    color: Colors.grey[300],
                    child: post.imageUrls.isNotEmpty
                        ? Image.network(
                      post.imageUrls[0]!,
                      fit: BoxFit.cover,
                    )
                        : Icon(Icons.image, color: Colors.white),
                  ),
                  title: Text(post.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.content.length > 15
                          ? '${post.content.substring(0, 15)}...'
                          : post.content),
                      Text('지역: ${post.tag}'),
                      FutureBuilder<int>(
                        future: _getProposersCount(post.documentId),
                        builder: (context, snapshot) {
                          final proposersCount = snapshot.data ?? 0;
                          return Text(
                              '참여인원: $proposersCount/${post.recruit}');
                        },
                      ),
                    ],
                  ),
                  trailing: FutureBuilder<bool>(
                    future: userId != null
                        ? _isLiked(post.documentId, userId!)
                        : Future.value(false),
                    builder: (context, snapshot) {
                      bool isLiked = snapshot.data ?? false;
                      return IconButton(
                        iconSize: 20.0, // 아이콘 크기를 줄임
                        padding: EdgeInsets.zero, // 패딩 제거
                        constraints: BoxConstraints(
                          minWidth: 24, // 최소 너비
                          minHeight: 24, // 최소 높이
                        ),
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : null,
                        ),
                        onPressed: () {
                          if (userId != null) {
                            _toggleFavorite(post.documentId, userId!);
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

  Future<int> _getProposersCount(String postId) async {
    final collection = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('proposers');
    final querySnapshot = await collection.get();
    return querySnapshot.size;
  }
}

//필터 옵션 디자인
class FilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const FilterButton({Key? key, required this.label, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}
