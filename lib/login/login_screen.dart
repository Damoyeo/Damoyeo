import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  Duration get loginTime => Duration(milliseconds: 2250);

  Future<String?> _authUser(LoginData data) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data.name,
        password: data.password,
      );
      return null; // 로그인 성공 시
    } catch (e) {
      return 'Invalid email or password'; // 로그인 실패 시 오류 메시지 반환
    }
  }

  Future<String?> _signUpUser(SignupData data) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data.name!,
        password: data.password!,
      );
      return null; // 회원가입 성공 시
    } catch (e) {
      return 'Error occurred during sign-up'; // 회원가입 실패 시 오류 메시지 반환
    }
  }

  Future<String?> _recoverPassword(String name) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: name);
      return null; // 비밀번호 재설정 이메일 발송 성공 시
    } catch (e) {
      return 'Email not found'; // 이메일이 없을 경우
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: '모임 시작',
      onLogin: _authUser,
      onSignup: _signUpUser,  // 수정된 함수 전달
      onRecoverPassword: _recoverPassword,
      theme: LoginTheme(
        primaryColor: Colors.blue,
        accentColor: Colors.white,
        titleStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
