import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdditionalInfoScreen extends StatelessWidget {
  final String uid;

  AdditionalInfoScreen(this.uid);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  Future<void> saveAdditionalInfo() async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': nameController.text,
      'nickname': nicknameController.text,
      'phone': phoneController.text,
    });

    // FirebaseAuthentication에 회원가입 성공하면 바로 로그인 상태로 변경됨
    // 로그인 화면으로 돌아가기 위해서 Firebase Authentication에서 로그아웃
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Additional Information')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: nicknameController,
              decoration: InputDecoration(labelText: '닉네임'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: '전화번호'),
              keyboardType: TextInputType.phone,
            ),
            ElevatedButton(
              onPressed: () async {
                await saveAdditionalInfo();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}