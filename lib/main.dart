import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gomoph/post/post_detail.dart';
import 'auth/auth_gate.dart'; // 로그인 화면으로 이동
import 'firebase_options.dart'; // Firebase 설정

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PostDetail(),
      //home: const AuthGate(),
    );
  }
}
