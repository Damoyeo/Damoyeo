import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_detail_page.dart';

// ChatPage: 채팅 목록을 보여주는 화면을 구성하는 Stateless 위젯
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  // Firestore에서 사용자 정보(닉네임과 프로필 사진)를 가져오는 함수
  Future<Map<String, dynamic>> getUserInfo(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return {
        'name': userDoc['name'] ?? 'Unknown',
        'profile_image': userDoc['profile_image'] ?? '',
      };
    }
    return {'name': 'Unknown', 'profile_image': ''};
  }

  // createOrGetChatRoom: 지정한 사용자 ID와 채팅방을 생성하거나 기존 채팅방을 가져오는 함수
  Future<String?> createOrGetChatRoom(String otherUserId) async {
    final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase 인증 객체
    final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore 데이터베이스 객체

    final currentUser = _auth.currentUser; // 현재 로그인한 사용자 가져오기
    if (currentUser == null) {
      print("No user is logged in."); // 로그인된 사용자가 없을 때 오류 메시지 출력
      return null;
    }

    final String currentUserId = currentUser.uid; // 현재 사용자의 ID

    // 현재 사용자가 포함된 모든 채팅방을 Firestore에서 조회
    final chatQuery = await _firestore
        .collection('chats')
        .where('users', arrayContains: currentUserId) // 현재 사용자가 포함된 채팅방만 필터링
        .get();

    // 다른 사용자가 포함된 채팅방이 이미 존재하는지 확인
    for (var doc in chatQuery.docs) {
      List<dynamic> users = doc['users'];
      if (users.contains(otherUserId)) {
        return doc.id; // 기존 채팅방 ID 반환
      }
    }

    // 새로운 채팅방 ID 생성
    String chatRoomId = _firestore.collection('chats').doc().id;

    // Firestore에 새 채팅방 생성
    await _firestore.collection('chats').doc(chatRoomId).set({
      'users': [currentUserId, otherUserId], // 채팅방에 포함된 사용자 목록
      'lastMessage': '', // 초기화된 마지막 메시지
      'timestamp': FieldValue.serverTimestamp(), // 채팅방 생성 시간
      'pinned': false, // 초기 상태에서 고정 여부는 false
    });

    return chatRoomId; // 새 채팅방 ID 반환
  }

  // showUserListDialog: 사용자 목록을 표시하여 채팅을 시작할 사용자를 선택하는 대화상자를 띄우는 함수
  Future<void> showUserListDialog(BuildContext context) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final currentUser = FirebaseAuth.instance.currentUser; // 현재 로그인한 사용자

    if (currentUser == null) return; // 로그인된 사용자가 없으면 함수 종료

    // 사용자 목록을 표시하는 대화상자 생성
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
                  style: TextStyle(fontSize: 18), // 제목 텍스트 스타일
                ),
              ),
              // Firestore에서 사용자 목록을 실시간 스트림으로 가져옴
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator()); // 데이터 로딩 중 표시
                  }

                  // 현재 사용자를 제외한 사용자 목록 필터링
                  final users = snapshot.data!.docs.where((user) => user.id != currentUser.uid);

                  // 사용자 목록을 표시하는 ListView
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final userDoc = users.elementAt(index); // 사용자 문서
                      final userId = userDoc.id; // 사용자 ID
                      final userName = userDoc['name'] ?? 'Unknown'; // 사용자 이름 (없으면 Unknown 표시)

                      return ListTile(
                        title: Text(userName), // 사용자 이름 표시
                        onTap: () async {
                          Navigator.pop(context); // 대화상자 닫기
                          final chatRoomId = await createOrGetChatRoom(userId); // 채팅방 생성 또는 가져오기
                          if (chatRoomId != null) {
                            // 채팅방으로 이동
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

  // pinChatRoom: 특정 채팅방을 상단 고정하는 함수
  Future<void> pinChatRoom(String chatRoomId) async {
    final _firestore = FirebaseFirestore.instance;
    await _firestore.collection('chats').doc(chatRoomId).update({
      'pinned': true, // 고정 상태를 true로 업데이트
    });
  }

  // unpinChatRoom: 특정 채팅방을 상단 고정 해제하는 함수
  Future<void> unpinChatRoom(String chatRoomId) async {
    final _firestore = FirebaseFirestore.instance;
    await _firestore.collection('chats').doc(chatRoomId).update({
      'pinned': false, // 고정 상태를 false로 업데이트
    });
  }

  // exitChatRoom: 현재 사용자가 특정 채팅방에서 나가도록 설정
  Future<void> exitChatRoom(String chatRoomId) async {
    final _firestore = FirebaseFirestore.instance;
    final currentUser = FirebaseAuth.instance.currentUser; // 현재 사용자 가져오기
    if (currentUser == null) return;

    // 현재 사용자를 채팅방의 'users' 배열에서 제거
    await _firestore.collection('chats').doc(chatRoomId).update({
      'users': FieldValue.arrayRemove([currentUser.uid]),
    });

    // 채팅방에 남아있는 사용자가 없는 경우 채팅방 삭제
    final updatedChatRoom = await _firestore.collection('chats').doc(chatRoomId).get();
    if (updatedChatRoom.exists) {
      final users = updatedChatRoom['users'] as List<dynamic>;
      if (users.isEmpty) {
        await _firestore.collection('chats').doc(chatRoomId).delete(); // 채팅방 삭제
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final currentUser = _auth.currentUser; // 현재 로그인한 사용자

    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅 목록'), // AppBar 제목
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 현재 사용자가 포함된 채팅방 목록을 실시간으로 가져옴
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('users', arrayContains: currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator()); // 데이터 로딩 중 표시
          }

          final chats = snapshot.data!.docs; // 채팅방 목록

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final chatId = chat.id; // 채팅방 ID
              final lastMessage = chat['lastMessage'] ?? ''; // 마지막 메시지
              final users = (chat['users'] as List).where((id) => id != currentUser.uid).toList();
              final otherUserId = users.isNotEmpty ? users.first : null; // 상대방 사용자 ID
              final isPinned = chat['pinned'] ?? false; // 채팅방 고정 상태

              if (otherUserId == null) {
                return const SizedBox.shrink(); // 다른 사용자가 없으면 빈 위젯 반환
              }

              return FutureBuilder<Map<String, dynamic>>(
                future: getUserInfo(otherUserId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(
                      title: Text('Loading...'),
                    );
                  }

                  final otherUserName = userSnapshot.data!['name'];
                  final profileImageUrl = userSnapshot.data!['profile_image'];

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage: profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : AssetImage('assets/default_profile.png') as ImageProvider,
                    ),
                    title: Text(otherUserName), // 가져온 사용자 이름 표시
                    subtitle: Text(lastMessage), // 마지막 메시지 표시
                    trailing: isPinned ? const Icon(Icons.push_pin) : null, // 고정 아이콘 표시
                    onTap: () {
                      // 채팅방으로 이동
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
                      // 하단 메뉴를 통해 채팅방 고정 및 나가기 기능 제공
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
                                    unpinChatRoom(chatId); // 고정 해제
                                  } else {
                                    pinChatRoom(chatId); // 고정
                                  }
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.exit_to_app),
                                title: const Text('채팅방 나가기'),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await exitChatRoom(chatId); // 채팅방 나가기
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showUserListDialog(context), // 사용자 목록 표시 대화상자
        child: const Icon(Icons.chat), // 채팅 아이콘
      ),
    );
  }
}
