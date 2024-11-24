import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gomoph/tab/chat/chat_detail_page.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../tab/chat/chat_page.dart';
import '../models/post.dart';
import '../tab/postList/postList_page.dart';
import '../main.dart';
import '../tab/tab_page.dart';


class PostDetail extends StatefulWidget {
  final Post post; // 전달받은 post 객체를 저장할 변수

  const PostDetail({super.key, required this.post});

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  // final List<String> _urls = const [
  //   'https://cdn.hankyung.com/photo/202409/01.37954272.1.jpg',
  //   'https://www.news1.kr/_next/image?url=https%3A%2F%2Fi3n.news1.kr%2Fsystem%2Fphotos%2F2024%2F8%2F20%2F6833973%2Fhigh.jpg&w=1920&q=75',
  //   'https://images.khan.co.kr/article/2023/07/26/news-p.v1.20230726.d22b5014f9664967853345853e5056fa_P1.jpg',
  //   'https://cdn.hankyung.com/photo/202409/01.37954272.1.jpg',
  // ];
  PageController _pageController = PageController();

  //bool isFavorite = false;

  @override
  void dispose() {
    _pageController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  // Future<void> _fetchProposersCount() async {  //신청 인원 구하는 함수
  //   try {
  //     final CollectionReference proposersRef = FirebaseFirestore.instance
  //         .collection('posts')
  //         .doc(widget.post.documentId)
  //         .collection('proposers');
  //
  //     // 문서 개수 가져오기
  //     final QuerySnapshot snapshot = await proposersRef.get();
  //     setState(() {
  //       proposersCount = snapshot.docs.length;
  //       isLoading = false; // 로딩 완료
  //     });
  //   } catch (e) {
  //     print('Error fetching proposers count: $e');
  //     setState(() {
  //       proposersCount = 0; // 오류 시 기본값 설정
  //       isLoading = false; // 로딩 완료
  //     });
  //   }
  // }

  // 날짜와 시간을 하나의 문자열로 형식화
  String _formatDateTime(DateTime? selectedDate) {
    if (selectedDate == null) {
      return '날짜가 정해지지 않았습니다.';
    }

    // 날짜를 "MM월 dd일 HH:mm" 형식으로 변환
    final DateFormat formatter = DateFormat('MM월 dd일 HH:mm');
    return formatter.format(selectedDate);
  }

  //좋아요 기능구현 -------------------------------------------------------------
  // 특정 사용자가 게시물을 좋아요 했는지 여부 확인
  Future<bool> _isLiked(String postId, String userId) async {
    final favoriteRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('favorite')
        .doc(userId);
    final docSnapshot = await favoriteRef.get();
    return docSnapshot.exists;
  }

  // 좋아요 추가/취소 기능
  Future<void> _toggleFavorite(String postId, String userId) async {
    final favoriteRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('favorite')
        .doc(userId);

    final isLiked = await _isLiked(postId, userId);

    if (isLiked) {
      // 좋아요 취소
      await favoriteRef.delete();
    } else {
      // 좋아요 추가
      await favoriteRef.set({
        'user_id': userId,
        'createdAt': Timestamp.now(),
      });
    }

    setState(() {}); // 좋아요 상태 업데이트
  }

  //좋아요 기능구현 -------------------------------------------------------------

  //신청 기능구현 -------------------------------------------------------------
  // 특정 사용자가 게시물을 신청 했는지 여부 확인
  Future<bool> _isProposers(String postId, String userId) async {
    final proposersRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('proposers')
        .doc(userId);
    final docSnapshot = await proposersRef.get();
    return docSnapshot.exists;
  }

  // 좋아요 추가/취소 기능
  Future<void> _toggleProposers(String postId, String userId) async {
    final proposersRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('proposers')
        .doc(userId);

    final isProposers = await _isProposers(postId, userId);

    if (isProposers) {
      // 좋아요 취소
      await proposersRef.delete();
    } else {
      // 좋아요 추가
      await proposersRef.set({
        'user_id': userId,
        'createdAt': Timestamp.now(),
      });
    }

    setState(() {}); // 좋아요 상태 업데이트
  }

  //신청 기능구현 -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final List<String> _urls = widget.post.imageUrls;
    //현재 사용자인지 확인하기 위함
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    print("currentUserId: $currentUserId");
    print("postId: ${widget.post.id}");

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Size _size = MediaQuery.of(context).size;
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  FutureBuilder<User?>(
                    future: FirebaseAuth.instance.authStateChanges().first, // 인증 상태 가져오기
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // 대기 상태일 경우 로딩 UI 반환
                        return SizedBox();
                      }

                      if (snapshot.hasData && widget.post.id == snapshot.data?.uid) {
                        // 현재 사용자가 작성자일 경우
                        return IconButton(
                          icon: Icon(Icons.more_vert),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                              ),
                              builder: (BuildContext context) {
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        title: Text('수정', style: TextStyle(fontSize: 18)),
                                        onTap: () {
                                          // 수정 기능 구현
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        title: Text('삭제', style: TextStyle(fontSize: 18)),
                                        onTap: () async {
                                          final shouldDelete = await showDialog<bool>(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text('삭제 확인'),
                                                content: Text('이 게시물을 삭제하시겠습니까?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, false), // 취소
                                                    child: Text('취소'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, true), // 확인
                                                    child: Text('삭제'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (shouldDelete == true) {
                                            try {
                                              // Firestore 문서 삭제
                                              await FirebaseFirestore.instance
                                                  .collection('posts')
                                                  .doc(widget.post.documentId) // Firestore 문서 ID
                                                  .delete();

                                              // 삭제 성공 메시지
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('게시물이 삭제되었습니다.')),
                                              );

                                              // TabPage로 이동
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(builder: (context) => const TabPage()), // TabPage로 이동
                                                    (Route<dynamic> route) => false, // 모든 이전 화면 제거
                                              );
                                            } catch (e) {
                                              // 에러 처리
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('게시물 삭제 중 오류가 발생했습니다: $e')),
                                              );
                                            }
                                          }
                                        },
                                      ),

                                      ListTile(
                                        title: Text('참여인원 확인', style: TextStyle(fontSize: 18)),
                                        onTap: () {
                                          // 참여인원 확인 기능 구현
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }

                      // 작성자가 아닐 경우 아무것도 반환하지 않음
                      return SizedBox();
                    },
                  ),
                ],

                expandedHeight: _size.width,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: _urls.isNotEmpty
                      ? SmoothPageIndicator(
                          controller: _pageController,
                          count: _urls.length,
                          effect: WormEffect(
                            dotColor: Color(0xffC5C6CC),
                            activeDotColor: Color(0xff006FFD),
                            radius: 2,
                            dotHeight: 4,
                            dotWidth: 4,
                          ),
                          onDotClicked: (index) {
                            _pageController.animateToPage(
                              index,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        )
                      : null,
                  centerTitle: true,
                  background: _urls.isNotEmpty
                      ? PageView.builder(
                          controller: _pageController,
                          allowImplicitScrolling: true,
                          itemBuilder: (context, item) {
                            return CachedNetworkImage(
                              imageUrl: _urls[item],
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              fit: BoxFit.cover,
                              scale: 0.1,
                            );
                          },
                          itemCount: _urls.length,
                        )
                      : Container(
                          color: Colors.grey,
                          child: Center(
                            child: Icon(
                              Icons.image,
                              color: Colors.white,
                              size: 100,
                            ),
                          ),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24, // 프로필 이미지 크기 설정
                                  backgroundImage: NetworkImage(
                                    'https://cdn.hankyung.com/photo/202409/01.37954272.1.jpg', // 여기에 실제 프로필 이미지 URL을 입력하세요
                                  ),
                                ),
                                SizedBox(width: 12), // 프로필 이미지와 닉네임 사이의 간격
                                Text(
                                  '닉네임',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            //현재 사용자가 작성자가 아닐 때만 버튼을 표시한다
                            if (widget.post.id != currentUserId)
                              IconButton(
                                icon: Icon(Icons.send, color: Colors.blue),
                                onPressed: () async {
                                  // 채팅방 ID를 가져오거나
                                  final chatPage = ChatPage(); //ChatPage인스턴스 생성
                                  final chatRoomId = await chatPage
                                      .createOrGetChatRoom(widget.post.id);

                                  // 채팅방이 정상적으로 생성되거나 가져왔을 경우에만 이동
                                  if (chatRoomId != null) {
                                    // 채팅방 화면으로 네비게이트
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatDetailPage(
                                          chatId: chatRoomId,
                                          otherUserId: widget.post.id,
                                        ), // ChatScreen은 채팅 화면 위젯
                                      ),
                                    );
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.post.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true, // 자동 줄바꿈
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${_formatDateTime(widget.post.meetingTime)}\n${widget.post.address} ${widget.post.detailAddress}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        widget.post.content,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: FutureBuilder<bool>(
                    future: _isProposers(
                        widget.post.documentId, currentUserId!), // 좋아요 상태 확인
                    builder: (context, snapshot) {
                      final isProposers = snapshot.data ?? false;

                      return ElevatedButton(
                        onPressed: isProposers
                            ? null // 신청 상태라면 버튼 비활성화
                            : () async {
                                // 신청 상태가 아니라면 참여하기 버튼 클릭 처리
                                await _toggleProposers(widget.post.documentId,
                                    currentUserId!); // 신청 상태 변경
                                print('참여하기 버튼 클릭');
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isProposers ? Colors.grey : Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isProposers
                              ? '신청 완료 1/${widget.post.recruit}' // 좋아요 상태일 때 표시
                              : '참여하기 1/${widget.post.recruit}',
                          // 좋아요 상태가 아닐 때 표시
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: FutureBuilder<bool>(
                    future: _isLiked(widget.post.documentId, currentUserId!),
                    // 좋아요 상태 확인
                    builder: (context, snapshot) {
                      final isFavorite = snapshot.data ?? false;

                      return Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Color(0xFF006FFD) : Colors.grey,
                      );
                    },
                  ),
                  onPressed: () async {
                    if (currentUserId != null) {
                      // 좋아요 토글
                      await _toggleFavorite(
                          widget.post.documentId, currentUserId!); // 좋아요 상태 변경
                    } // UI 갱신
                    else {
                      print("User not logged in");
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
