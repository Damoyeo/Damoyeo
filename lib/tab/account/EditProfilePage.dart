import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_app_check/firebase_app_check.dart';

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

  // 이미지 크기 제한 (5MB)
  static const int maxFileSize = 5 * 1024 * 1024;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 현재 사용자 데이터 로드
  void _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';

      // Firestore에서 사용자 정보 가져오기
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        _nicknameController.text = data?['user_nickname'] ?? '';
        _phoneNumController.text = data?['user_phoneNum'] ?? '';

        // 프로필 이미지 URL 설정
        setState(() {
          _profileImageUrl = data?['profile_image'];
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? downloadURL;

      // 이미지가 선택된 경우에만 Storage 업로드 실행
      if (_images.isNotEmpty) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${user.uid}.jpg');

        final uploadTask = storageRef.putFile(File(_images.first!.path));
        final snapshot = await uploadTask;
        downloadURL = await snapshot.ref.getDownloadURL();
        print("Image uploaded. URL: $downloadURL");
      }

      // Firestore에 nickname, phone, profile_image 업데이트
      final updateData = {
        'user_nickname': _nicknameController.text, // 닉네임 업데이트
        'user_phone': _phoneNumController.text,   // 전화번호 업데이트
      };

      // 이미지가 선택된 경우에만 profile_image 추가
      if (downloadURL != null) {
        updateData['profile_image'] = downloadURL;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        updateData,
        SetOptions(merge: true),
      );

      // 저장 성공 시 이전 화면으로 이동
      Navigator.pop(context, true);
    } on FirebaseException catch (e) {
      print("Error updating profile: ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  final ImagePicker _picker = ImagePicker();
  List<XFile?> _images = []; // 업로드된 이미지 목록
  Future<void> _pickImage(ImageSource source) async {
    if (_images.length >= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("이미지는 최대 1개까지 업로드할 수 있습니다.")),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      final file = File(image.path);
      final fileSize = await file.length();

      if (fileSize > maxFileSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("이미지 크기는 5MB 이하로 선택해 주세요.")),
        );
      } else {
        setState(() {
          _images.add(image);
          _profileImageFile = image;  // 선택한 이미지를 프로필 이미지로 설정
          print("Image selected: ${image.path}");  // 이미지 경로 출력
        });
      }
    } else {
      print("No image selected.");
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
              title: Text('카메라'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('갤러리'),
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
                                  heroTag: 'floatingButton1',
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
                                  heroTag: 'floatingButton2',
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
