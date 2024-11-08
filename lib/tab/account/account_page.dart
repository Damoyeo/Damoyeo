import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'EditProfilePage.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? _profileImageUrl; // 현재 프로필 이미지 URL

  @override
  void initState() {
    super.initState();
    _loadUserProfileImageUrl();
  }

  // Firestore에서 프로필 이미지 URL을 로드
  Future<void> _loadUserProfileImageUrl() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _profileImageUrl = doc.data()?['profile_image'];
      });
    }
  }

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
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircleAvatar(
                            backgroundImage: _profileImageUrl != null
                                ? NetworkImage(_profileImageUrl!)
                                : const NetworkImage(
                                'https://image.ajunews.com/content/image/2018/08/20/20180820161422688695.jpg'), // 기본 이미지
                            backgroundColor: Colors.grey,
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
            const Divider(height: 32), // 구분선 추가
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: Text('내 정보 수정'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () async {
                      // 내 정보 수정 페이지로 이동
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => EditProfilePage()),
                      );

                      // 프로필 정보가 갱신되었을 경우에만 이미지 즉시 다시 로드
                      if (result == true) {
                        setState(() {
                          _loadUserProfileImageUrl(); // 프로필 이미지 갱신
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('프로필이 업데이트되었습니다.')),
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
