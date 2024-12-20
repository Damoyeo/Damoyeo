import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'EditProfilePage.dart';
import 'EditPassword_page.dart';
import '../myActivity/MyActivity_page.dart';
import '../../auth/auth_gate.dart';

class AccountPage extends StatefulWidget {
  final String userId; // 전달받은 유저 ID

  const AccountPage({Key? key, required this.userId}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? _currentUserId; // 현재 로그인된 사용자 ID
  String? _profileImageUrl; // 현재 프로필 이미지 URL
  String? _nickname; // 닉네임
  int _posts = 0; // 게시물 수
  int _followers = 0; // 팔로워 수
  int _following = 0; // 팔로잉 수
  late String userId;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid; // 현재 로그인한 사용자 ID 가져오기
    userId = widget.userId;
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
          _nickname = data?['user_nickname'];
          _posts = data?['user_PostCount'] ?? 0;
          _followers = data?['followers'] ?? 0;
          _following = data?['following'] ?? 0;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthGate()),
            (route) => false, // 이전 모든 화면 제거
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = _currentUserId == widget.userId; // 현재 프로필이 본인인지 확인

    return Scaffold(
      appBar: AppBar(
        title: const Text('다모여'),
        actions: isCurrentUser
            ? [
          IconButton(
            onPressed: () => _logout(context), // 로그아웃 함수 호출
            icon: const Icon(Icons.exit_to_app),
          ),
        ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 120, // 프로필 이미지 크기 설정
                        height: 120,
                        child: CircleAvatar(
                          backgroundImage: _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : const AssetImage('assets/default_profile.jpg') as ImageProvider,
                          backgroundColor: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _nickname ?? '닉네임 없음',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      '$_posts',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      '게시물',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32), // 구분선 추가
            Expanded(
              child: ListView(
                children: [
                  if (isCurrentUser) // 본인 프로필일 때만 보이도록 조건 추가
                    ListTile(
                      title: const Text('내 정보 수정'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const EditProfilePage()),
                        );

                        if (result == true) {
                          _loadUserProfileData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('프로필이 업데이트되었습니다.')),
                          );
                        }
                      },
                    ),
                  if (isCurrentUser) // 본인 프로필일 때만 보이도록 조건 추가
                    ListTile(
                      title: const Text('비밀번호 변경'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const EditPasswordPage()),
                        );
                      },
                    ),
                  ListTile(
                    title: const Text('활동 내역'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (
                            context) => MyActivityPage(userId: userId,)),

                      );
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