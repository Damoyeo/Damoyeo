import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instagram Clone'),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.exit_to_app)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 균등한
          children: [
            Column(
              children: [
                Stack(
                  children: [
                    const SizedBox(
                      width: 80,
                      height: 80,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                            'https://image.ajunews.com/content/image/2018/08/20/20180820161422688695.jpg'),
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      alignment: Alignment.bottomRight,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: FloatingActionButton(
                              onPressed: null,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.add),
                            ),
                          ),
                          SizedBox(
                            width: 25,
                            height: 25,
                            child: FloatingActionButton(
                              onPressed: null,
                              child: Icon(Icons.add),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                const Text(
                  '이소룡',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  '3',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  '게시물',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            const Column(
              children: [
                Text(
                  '0',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  '팔로워',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            const Column(
              children: [
                Text(
                  '0',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  '팔로잉',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
