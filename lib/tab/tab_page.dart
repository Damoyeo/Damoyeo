import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gomoph/tab/favorite/favorite_page.dart';
import 'package:gomoph/tab/myActivity/MyActivity_page.dart';
import 'package:gomoph/tab/postList/postList_page.dart';
import 'package:gomoph/tab/search/search_page.dart';

import 'account/account_page.dart';
import 'home/home_page.dart';
import 'chat/chat_page.dart';

class TabPage extends StatefulWidget {
  const TabPage({super.key});

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  int _currentIndex = 2; // 게시물 리스트 페이지가 가장 먼저 나타나게

  // 현재 사용자 ID를 가져오는 메서드
  String? _getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = _getCurrentUserId();

    // 현재 사용자 ID가 null인 경우 처리 (로그아웃 상태 처리)
    if (currentUserId == null) {
      return const Center(
        child: Text('로그인되지 않았습니다.'),
      );
    }

    // 각 페이지에 현재 사용자 ID를 전달
    final _pages = [
      const FavoritePage(),
      const ChatPage(),
      PostListPage(),
      const MyActivityPage(),
      AccountPage(userId: currentUserId), // 사용자 ID 전달
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 네비게이션 바를 5개 이상 띄우기 위해 필요
        currentIndex: _currentIndex, // 현재 인덱스를 지정하여 활성화 상태를 표시
        onTap: (index) { // 클릭했을 때 해당 인덱스로 값이 변하면서 탭이 넘어감
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '찜목록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: '게시물',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: '활동',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
    );
  }
}
