import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'EditProfilePage.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // 로그아웃 수행
    Navigator.of(context).pushReplacementNamed('/login'); // 로그인 페이지로 이동
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instagram Clone'),
        actions: [
          IconButton(
            onPressed: () => _logout(context), // 로그아웃 함수 호출
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          child: const Stack(
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
                    const SizedBox(height: 8),
                    const Text(
                      '이소룡',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Column(
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
            Divider(height: 32), // 구분선 추가
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: Text('내 정보 수정'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () async {
                      // 내 정보 수정 페이지로 이동
                      // EditProfilePage에서 알림 정보가 올 때 까지 대기
                      final result = await Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => EditProfilePage()),
                      );

                      // result가 null이 아니고 메시지가 있다면 성공 스낵바 표시
                      if (result != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result.toString())),
                        );
                      }
                    },
                  ),
                  ListTile(
                    title: Text('비밀번호 변경'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // 비밀번호 변경 페이지로 이동하는 로직
                    },
                  ),
                  ListTile(
                    title: Text('활동 내역'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // 활동 내역 페이지로 이동하는 로직
                    },
                  ),
                  ListTile(
                    title: Text('작성글 내역'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // 작성글 내역 페이지로 이동하는 로직
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
