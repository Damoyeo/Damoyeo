import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gomoph/tab/chat/chat_detail_page.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../tab/chat/chat_page.dart';
import '../models/post.dart';

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
  bool isFavorite = false;

  @override
  void dispose() {
    _pageController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  // 날짜와 시간을 하나의 문자열로 형식화
  String _formatDateTime(DateTime? selectedDate) {
    if (selectedDate == null) {
      return '날짜가 정해지지 않았습니다.';
    }

    // 날짜를 "MM월 dd일 HH:mm" 형식으로 변환
    final DateFormat formatter = DateFormat('MM월 dd일 HH:mm');
    return formatter.format(selectedDate);
  }

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
                actions: [ //작성자이면 버튼이 나오게. 아니면 숨김.
                  widget.post.id == FirebaseAuth.instance.currentUser?.uid ?
                  IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (BuildContext context) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: Text('수정',
                                      style: TextStyle(fontSize: 18)),
                                  onTap: () {
                                    // 수정 기능 구현
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: Text('삭제',
                                      style: TextStyle(fontSize: 18)),
                                  onTap: () {
                                    // 삭제 기능 구현
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: Text('참여인원 확인',
                                      style: TextStyle(fontSize: 18)),
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
                  ) : Container(),
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
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
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
                                  final chatRoomId = await chatPage.createOrGetChatRoom(widget.post.id);

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
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '참여하기 1/${widget.post.recruit}',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Color(0xFF006FFD) : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      isFavorite = !isFavorite; // 즐겨찾기 상태를 토글
                    });
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
