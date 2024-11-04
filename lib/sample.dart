// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
//
// // 이미지 업로드 함수
// Future<String> uploadImage(XFile image) async {
//   final storageRef = FirebaseStorage.instance.ref().child('posts/${image.name}');
//   final uploadTask = storageRef.putFile(File(image.path));
//   final snapshot = await uploadTask.whenComplete(() => null);
//   final downloadUrl = await snapshot.ref.getDownloadURL();
//   return downloadUrl;
// }
//
// // Firestore에 게시물과 이미지 URL 저장 함수
// Future<void> savePostWithImageUrl(Post post, XFile image) async {
//   final imageUrl = await uploadImage(image);
//   final postWithImageUrl = post.copyWith(imageUrl: imageUrl);  // imageUrl 추가
//   await FirebaseFirestore.instance.collection('posts').doc(post.id).set(postWithImageUrl.toJson());
// }



//좋아요 개수 가져오기
/*
Future<int> getFavoriteCount(String postId) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('posts')
      .doc(postId)
      .collection('favorite')
      .get();

  return snapshot.size;
}

 */