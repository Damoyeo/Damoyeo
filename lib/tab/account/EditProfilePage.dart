import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _phoneNumController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? _profileImageUrl; // Fire Storage 이미지 url
  XFile? _profileImageFile; // 프로필 이미지 파일

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 현재 사용자 데이터 로드
  void _loadUserData() {
    final user = _auth.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';

      // Firestore에서 사용자 정보 가져오기
      FirebaseFirestore.instance.collection('users').doc(user.uid).get().then((doc) {
        if (doc.exists) {
          final data = doc.data();
          _nicknameController.text = data?['nickname'] ?? '';
          _phoneNumController.text = data?['phone'] ?? '';
          setState(() {
            _profileImageUrl = data?['profileImageUrl'];
          });
        }
      });
    }
  }

  Future<void> _updateProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {

      // 선택된 이미지가 있을 경우, Firebase Storage에 업로드 후 URL 가져오기
      String? imageUrl;
      if (_profileImageFile != null) {
        imageUrl = await _uploadImageToStorage(_profileImageFile!);
      }

      // Firestore에 닉네임과 전화번호 저장
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'nickname': _nicknameController.text,
        'phone': _phoneNumController.text,
        'profileImageUrl': imageUrl ?? _profileImageUrl, // 이미지 URL이 있다면 업데이트
      }, SetOptions(merge: true)); // 새로운 데이터만 업데이트하는 기능

      // 저장 성공 시, 이전 화면으로 이동
      // 성공 메시지를 포함
      Navigator.pop(context, '프로필이 업데이트되었습니다.');

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Firebase Storage에 이미지 업로드 후 다운로드 URL 반환
  Future<String?> _uploadImageToStorage(XFile imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}_profile.jpg');

      // 이미지 파일을 업로드
      await storageRef.putFile(File(imageFile.path));

      // 다운로드 URL을 반환
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  final ImagePicker _picker = ImagePicker();
  List<XFile?> _images = []; // 업로드된 이미지 목록
  Future<void> _pickImage(ImageSource source) async {
    if (_images.length >= 2) {
      // 이미 5개의 이미지가 있으면 알림을 표시하고 반환
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("이미지는 최대 1개까지 업로드할 수 있습니다.")),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _images.add(image);
      });
    }
  }

  // 이미지 선택
  void showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nicknameController.dispose();
    _phoneNumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 정보 수정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              children: [
                GestureDetector(
                  onTap: showImagePickerOptions,
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: CircleAvatar(
                          backgroundImage: _profileImageFile != null
                              ? FileImage(File(_profileImageFile!.path))
                              : (_profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!) as ImageProvider
                              : const AssetImage('assets/default_profile.jpg')),
                        ),
                      ),
                      Container(
                        width: 160,
                        height: 160,
                        alignment: Alignment.bottomRight,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            GestureDetector(
                              onTap: showImagePickerOptions,
                              child: const SizedBox(
                                width: 28,
                                height: 28,
                                child: FloatingActionButton(
                                  onPressed: null,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.edit),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: showImagePickerOptions,
                              child: const SizedBox(
                                width: 25,
                                height: 25,
                                child: FloatingActionButton(
                                  onPressed: null,
                                  child: Icon(Icons.edit),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '이름'),
              enabled: false, // 수정 불가
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: '이메일'),
              enabled: false, // 수정 불가
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(labelText: '닉네임'),
            ),
            TextField(
              controller: _phoneNumController,
              decoration: InputDecoration(labelText: '전화번호'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator() // 로딩 이미지
                : ElevatedButton(
              onPressed: _updateProfile,
              child: Text('프로필 수정 저장'),
            ),
          ],
        ),
      ),
    );
  }
}
