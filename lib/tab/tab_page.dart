import 'package:flutter/material.dart';
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
  int _currentIndex = 0;

  //채팅 페이지 추가필요
  final _pages = [
    const HomePage(),
    const SearchPage(),
    const AccountPage(),
    const ChatPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black, // 네비게이션 바 배경색 설정
        selectedItemColor: Colors.blue, // 선택된 아이템 색상 설정
        unselectedItemColor: Colors.grey, // 선택되지 않은 아이템 색상 설정
        currentIndex: _currentIndex,
        onTap: (index) {  // 클릭 했을 때 해당 인덱스로 값이 변하면서 탭이 넘어감
          setState(() {
            currentIndex: _currentIndex;
          });
          _currentIndex = index;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}
