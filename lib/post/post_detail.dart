import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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

  @override
  Widget build(BuildContext context) {
    final List<String> _urls = widget.post.imageUrls;
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
                  ),
                ],
                expandedHeight: _size.width,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: SmoothPageIndicator(
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
                  ),
                  centerTitle: true,
                  background: PageView.builder(
                    controller: _pageController,
                    allowImplicitScrolling: true,
                    itemBuilder: (context, item) {
                      return CachedNetworkImage(
                        imageUrl: _urls[item],
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        fit: BoxFit.cover,
                        scale: 0.1,
                      );
                    },
                    itemCount: _urls.length,
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
                            Icon(Icons.send, color: Colors.blue),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            widget.post.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '10월 15일 17:00~19:00\n${widget.post.address} ${widget.post.detailAddress}',
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
