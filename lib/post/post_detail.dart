import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PostDetail extends StatefulWidget {
  const PostDetail({super.key});

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  final List<String> _urls = const [
    'https://cdn.hankyung.com/photo/202409/01.37954272.1.jpg',
    'https://www.news1.kr/_next/image?url=https%3A%2F%2Fi3n.news1.kr%2Fsystem%2Fphotos%2F2024%2F8%2F20%2F6833973%2Fhigh.jpg&w=1920&q=75',
    'https://images.khan.co.kr/article/2023/07/26/news-p.v1.20230726.d22b5014f9664967853345853e5056fa_P1.jpg',
    'https://cdn.hankyung.com/photo/202409/01.37954272.1.jpg',
  ];
  PageController _pageController = PageController();
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
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
                      activeDotColor: Theme.of(context).primaryColor,
                      dotColor: Theme.of(context).colorScheme.background,
                      radius: 2,
                      dotHeight: 4,
                      dotWidth: 4,
                    ),
                    onDotClicked: (index) {},
                  ),
                  centerTitle: true,
                  background: PageView.builder(
                    allowImplicitScrolling: true,
                    itemBuilder: (context, item) {
                      return Image.network(
                        _urls[item],
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '스터디원 모집',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.send, color: Colors.blue),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '10월 15일 17:00~19:00\n서울특별시 성북구 삼성교로16길 116',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '공부 열심히 하실분 구해요\n'
                        '저희는 고급 모바일 프로그래밍에 대해 공부하려고 합니다.\n'
                        '참여할 마음만 있으시면 됩니다.\n'
                        '공부 열심히 하실분 구해요\n'
                        '저희는 고급 모바일 프로그래밍에 대해 공부하려고 합니다.\n'
                        '참여할 마음만 있으시면 됩니다.\n'
                        '공부 열심히 하실분 구해요\n'
                        '저희는 고급 모바일 프로그래밍에 대해 공부하려고 합니다.\n'
                        '참여할 마음만 있으시면 됩니다.\n'
                        '공부 열심히 하실분 구해요\n'
                        '저희는 고급 모바일 프로그래밍에 대해 공부하려고 합니다.\n'
                        '참여할 마음만 있으시면 됩니다.\n'
                        '공부 열심히 하실분 구해요\n'
                        '저희는 고급 모바일 프로그래밍에 대해 공부하려고 합니다.\n'
                        '참여할 마음만 있으시면 됩니다.\n'
                        '공부 열심히 하실분 구해요\n'
                        '저희는 고급 모바일 프로그래밍에 대해 공부하려고 합니다.\n'
                        '참여할 마음만 있으시면 됩니다.\n'
                        '공부 열심히 하실분 구해요\n'
                        '저희는 고급 모바일 프로그래밍에 대해 공부하려고 합니다.\n'
                        '참여할 마음만 있으시면 됩니다.\n'
                        '공부 열심히 하실분 구해요\n',
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
                      '참여하기 1/6',
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
