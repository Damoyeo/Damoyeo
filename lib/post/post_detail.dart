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
                    onPressed: () {},
                  ),
                ],
                expandedHeight: _size.width,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(children: [
                    PageView.builder(
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
                    Positioned(
                      bottom: 16,
                      right: 0,
                      left: 0,
                      child: Container(
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: _urls.length,
                          effect: WormEffect(
                            activeDotColor: Theme.of(context).primaryColor,
                            dotColor: Theme.of(context).colorScheme.background,
                            radius: 4,
                            dotHeight: 8,
                            dotWidth: 8,
                          ),
                          onDotClicked: (index) {},
                        ),
                      ),
                    )
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: _size.height * 2,
                  color: Colors.lightGreenAccent,
                  child: Center(
                    child: Text('안녕하세요'),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
