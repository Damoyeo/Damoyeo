import 'package:flutter/material.dart';
import 'package:gomoph/tab/search/search_page.dart';

import 'account/account_page.dart';
import 'home/home_page.dart';

class TabPage extends StatefulWidget {
  const TabPage({super.key});

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  int _currentIndex = 0;

  final _pages = [
    const HomePage(),
    const SearchPage(),
    const AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
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
        ],
      ),
    );
  }
}
