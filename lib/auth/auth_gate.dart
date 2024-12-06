import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../login/login_screen.dart'; // flutter_login으로 구성된 로그인 화면
import '../tab/tab_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return const TabPage(); // 인증된 경우 메인 화면으로 이동
        } else {
          return LoginScreen(); // 인증되지 않은 경우 로그인 화면 표시
        }
      },
    );
  }
}
