import 'package:flutter/material.dart';
import 'package:gomoph/tab/favorite/favorite_page.dart';
import 'package:gomoph/tab/myActivity/MyActivity_page.dart';
import 'package:gomoph/tab/postList/postList_page.dart';
import 'package:gomoph/tab/search/search_page.dart';

import 'account/account_page.dart';


class TabPage extends StatefulWidget {
  const TabPage({super.key});

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  int _currentIndex = 3; //게시물리스트페이지가 가장먼제 나타나게

  final _pages = [
    const FavoritePage(),
    const SearchPage(),
    PostListPage(),
    const MyActivityPage(),
    const AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, //네비게이션바를 5개 이상 띄우기위해 필요
        
        currentIndex: _currentIndex,  // 현재 인덱스를 지정하여 활성화 상태를 표시
        onTap: (index) {  // 클릭했을 때 해당 인덱스로 값이 변하면서 탭이 넘어감
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
