import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'EditProfilePage.dart';

class AccountPage extends StatefulWidget {
  final String userId; // 전달받은 유저 ID

  const AccountPage({Key? key, required this.userId}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? _profileImageUrl; // 현재 프로필 이미지 URL
  String? _nickname; // 닉네임
  int _posts = 0; // 게시물 수
  int _followers = 0; // 팔로워 수
  int _following = 0; // 팔로잉 수

  @override
  void initState() {
    super.initState();
    _loadUserProfileData();
  }

  // Firestore에서 유저 데이터를 로드
  Future<void> _loadUserProfileData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _profileImageUrl = data?['profile_image'];
          _nickname = data?['nickname'];
          _posts = data?['posts'] ?? 0;
          _followers = data?['followers'] ?? 0;
          _following = data?['following'] ?? 0;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
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
            icon: const Icon(Icons.exit_to_app),
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
                                ? Image.network(_profileImageUrl!).image
                                : const AssetImage('assets/default_profile.png'),
                            backgroundColor: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _nickname ?? '닉네임 없음',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '$_posts',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Text(
                      '게시물',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '$_followers',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Text(
                      '팔로워',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '$_following',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Text(
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
                    title: const Text('내 정보 수정'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      // 내 정보 수정 페이지로 이동
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => EditProfilePage()),
                      );

                      // 프로필 정보가 갱신되었을 경우에만 이미지 즉시 다시 로드
                      if (result == true) {
                        _loadUserProfileData(); // 프로필 데이터 갱신
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('프로필이 업데이트되었습니다.')),
                        );
                      }
                    },
                  ),
                  const ListTile(
                    title: Text('비밀번호 변경'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  const ListTile(
                    title: Text('활동 내역'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  const ListTile(
                    title: Text('작성글 내역'),
                    trailing: Icon(Icons.chevron_right),
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
