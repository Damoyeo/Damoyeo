import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gomoph/models/post.dart';

class CreateModel {
  Future<void> uploadPost(String title, String content, String tag,
      int recruit, DateTime createdAt, String imageUrl, List<File> imageFiles) async {

    /////////이미지 저장 후 리스트 리턴
    List<String> imageUrls = [];

    // 모든 이미지 파일을 업로드하고 URL을 리스트에 추가
    for (File file in imageFiles) {
      String url = await uploadImage(file);
      imageUrls.add(url);
    }
    ////////////////

    final postRef =
    FirebaseFirestore.instance.collection('posts').withConverter<Post>(
      fromFirestore: (snapshot, _) => Post.fromJson(snapshot.data()!),
      toFirestore: (post, _) => post.toJson(),
    );
    postRef.add(Post(id: FirebaseAuth.instance.currentUser?.uid ?? '',
        title: title,
        content: content,
        tag: tag,
        createdAt: createdAt,
        recruit: recruit,
        imageUrl: imageUrl,
        imageUrls: imageUrls));
  }

  // 이미지를 firestore에 올리고 url을 리턴
  Future<String> uploadImage(File imageFile) async {
    // Firebase Storage의 참조 경로 생성 (예: 'images/파일명')
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef = FirebaseStorage.instance.ref().child('images/$fileName');

    // 파일을 Firebase Storage에 업로드
    await storageRef.putFile(imageFile);

    // 업로드한 파일의 다운로드 URL 가져오기
    String downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  }
}
