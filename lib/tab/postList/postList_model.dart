import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/post.dart';

class PostListModel{
  final Stream<QuerySnapshot> postsStream =
      FirebaseFirestore.instance.collection('posts')
          .withConverter<Post>(
          fromFirestore: (snapshot, _) => Post.fromJson(snapshot.data()!, snapshot.id),
          toFirestore: (post, _) => post.toJson(),
      )
          .snapshots();

}