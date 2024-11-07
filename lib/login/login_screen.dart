import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isLoginMode = true;

  Future<void> _authenticateUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      UserCredential userCredential;
      if (isLoginMode) {
        // 로그인 모드
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } else {
        // 회원가입 모드
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // 회원가입이 성공한 후 Firestore에 추가 정보 저장
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'user_name': nameController.text.trim(),
          'user_nickname': nicknameController.text.trim(),
          'user_phoneNum': phoneController.text.trim(),
          'user_email': emailController.text.trim(),
          'user_createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 인증 성공 시 다음 화면으로 이동하거나 처리 추가
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isLoginMode ? 'Logged in successfully' : 'Sign-up successful')),
      );
    } catch (error) {
      // 오류 발생 시 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLoginMode ? '로그인' : '회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(
                width: 80,
                height: 80,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://image.ajunews.com/content/image/2018/08/20/20180820161422688695.jpg'),
                ),
              ),
              // 이메일 입력 필드
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: '이메일'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return '이메일 형식에 맞지 않습니다. 올바르게 입력해 주세요.';
                  }
                  return null;
                },
              ),
              // 비밀번호 입력 필드
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: '패스워드'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              // 이름 입력 필드 (회원가입 시에만 표시)
              if (!isLoginMode)
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: '이름'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이름을 입력해주세요';
                    }
                    return null;
                  },
                ),
              if (!isLoginMode)
                TextFormField(
                  controller: nicknameController,
                  decoration: InputDecoration(labelText: '닉네임'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '닉네임을 입력해주세요';
                    }
                    return null;
                  },
                ),
              // 전화번호 입력 필드 (회원가입 시에만 표시)
              if (!isLoginMode)
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: '전화번호'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '휴대폰 번호를 입력해주세요';
                    }
                    return null;
                  },
                ),
              SizedBox(height: 20),
              // 회원가입/로그인 버튼
              ElevatedButton(
                onPressed: _authenticateUser,
                child: Text(isLoginMode ? '로그인' : '회원가입'),
              ),
              // 로그인/회원가입 모드 전환 버튼
              TextButton(
                onPressed: () {
                  setState(() {
                    isLoginMode = !isLoginMode;
                  });
                },
                child: Text(isLoginMode
                    ? '계정이 없으신가요?'
                    : '이미 계정이 있으신가요?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
