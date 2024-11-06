import 'package:flutter/material.dart';

class MyActivityPage extends StatelessWidget {
  const MyActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("활동"),
      ),
      body: Center(
        child: Text("활동 페이지 내용"),
      ),
    );
  }
}
