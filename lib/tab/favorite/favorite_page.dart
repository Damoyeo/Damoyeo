import 'package:flutter/material.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("찜 목록"),
      ),
      body: Center(
        child: Text("찜 목록 페이지 내용"),
      ),
    );
  }
}
