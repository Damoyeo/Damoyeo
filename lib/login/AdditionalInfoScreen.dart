import 'package:cloud_firestore/cloud_firestore.dart';
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
                Navigator.pop(context); // 저장 후 로그인 화면으로 돌아가기
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}