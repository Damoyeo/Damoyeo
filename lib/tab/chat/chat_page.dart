import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_detail_page.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  //새로운 사용자와의 채팅방을 생성하거나 이전의 채팅방으로 참여하는 코드
  //나중에 진호가 버튼만들면 이 함수로 채팅방을 생성하여야 한다.
  Future<String?> createOrGetChatRoom(String otherUserId) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print("No user is logged in.");
      return null;
    }

    final String currentUserId = currentUser.uid;

    // 기존 채팅방이 있는지 확인
    final chatQuery = await _firestore
        .collection('chats')
        .where('users', arrayContains: currentUserId)
        .get();

    // 상대방의 UID가 포함된 기존 채팅방이 있으면 해당 채팅방 ID 반환
    for (var doc in chatQuery.docs) {
      List<dynamic> users = doc['users'];
      if (users.contains(otherUserId)) {
        return doc.id;
      }
    }

    // 기존 채팅방이 없다면 새로 생성
    String chatRoomId = _firestore.collection('chats').doc().id;

    await _firestore.collection('chats').doc(chatRoomId).set({
      'users': [currentUserId, otherUserId],
      'lastMessage': '',
      'timestamp': FieldValue.serverTimestamp(),
      'pinned': false, //기본값 추가
    });

    return chatRoomId;
  }

  Future<void> showUserListDialog(BuildContext context) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Select a user to chat with",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!.docs.where((user) => user.id != currentUser.uid);

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final userDoc = users.elementAt(index);
                      final userId = userDoc.id;
                      final userName = userDoc['name'] ?? 'Unknown';

                      return ListTile(
                        title: Text(userName),
                        onTap: () async {
                          Navigator.pop(context); // 다이얼로그 닫기
                          final chatRoomId = await createOrGetChatRoom(userId);
                          if (chatRoomId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatDetailPage(
                                  chatId: chatRoomId,
                                  otherUserId: userId,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> pinChatRoom(String chatRoomId) async {
    final _firestore = FirebaseFirestore.instance;
    await _firestore.collection('chats').doc(chatRoomId).update({
      'pinned': true,
    });
  }

  Future<void> unpinChatRoom(String chatRoomId) async {
    final _firestore = FirebaseFirestore.instance;
    await _firestore.collection('chats').doc(chatRoomId).update({
      'pinned': false,
    });
  }

  Future<void> exitChatRoom(String chatRoomId) async {
    final _firestore = FirebaseFirestore.instance;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await _firestore.collection('chats').doc(chatRoomId).update({
      'users': FieldValue.arrayRemove([currentUser.uid]),
    });
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅 목록'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 로그인한 사용자가 포함된 채팅방 목록 가져오기
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('users', arrayContains: currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final chatId = chat.id;
              final lastMessage = chat['lastMessage'] ?? '';
              final otherUserId = (chat['users'] as List)
                  .firstWhere((id) => id != currentUser.uid);
              final isPinned = chat['pinned'] ?? false;

              return ListTile(
                title: Text("Chat with $otherUserId"),
                subtitle: Text(lastMessage),
                trailing: isPinned ? const Icon(Icons.push_pin) : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailPage(
                        chatId: chatId,
                        otherUserId: otherUserId,
                      ),
                    ),
                  );
                },
                onLongPress: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.push_pin),
                            title: Text(isPinned ? '채팅방 상단 고정 해제' : '채팅방 상단 고정'),
                            onTap: () {
                              Navigator.pop(context);
                              if (isPinned) {
                                unpinChatRoom(chatId);
                              } else {
                                pinChatRoom(chatId);
                              }
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.exit_to_app),
                            title: const Text('채팅방 나가기'),
                            onTap: () async {
                              Navigator.pop(context);
                              await exitChatRoom(chatId);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showUserListDialog(context), // 사용자 목록 다이얼로그 열기
        child: const Icon(Icons.chat),
      ),
    );
  }
}
