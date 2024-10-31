import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instagram Clone'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text('Instagram에 오신 것을 환영합니다',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text('사진과 동영상을 보려면 팔로우하세요'),
            SizedBox(height: 20),
            Card(
              elevation: 4.0, // 그림자
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage('https://image.ajunews.com/content/image/2018/08/20/20180820161422688695.jpg'),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('BruceLee@instagram.com',
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text('김이소룡'),
                    SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,  // 사진을 중앙으로 오도록 함
                      children: [
                        Image.network("https://cdn.cwoneconomy.com/news/photo/202307/817_768_4635.jpg",
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 4),
                        Image.network("https://ojsfile.ohmynews.com/STD_IMG_FILE/2017/0725/IE002193665_STD.jpg",
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 4),
                        Image.network("https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Bruce_Lee_1973.jpg/250px-Bruce_Lee_1973.jpg",
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('Facebook 친구'),
                    SizedBox(height: 8),
                    ElevatedButton(
                        onPressed: () {},
                        child: Text('팔로우'),
                    ),
                  ],
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}
