import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId; // 채팅방 ID
  final String otherUserId; // 상대방 사용자 ID

  const ChatDetailPage({
    Key? key,
    required this.chatId,
    required this.otherUserId,
  }) : super(key: key);

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _controller = TextEditingController(); // 입력 필드 제어용 컨트롤러
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase 인증 객체
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore 데이터베이스 객체

  String otherUserName = "Loading..."; // 상대방 사용자 이름을 저장할 변수
  String otherName = "Loading...";
  String? otherUserProfileImage; // 상대방 프로필 이미지를 저장할 변수

  @override
  void initState() {
    super.initState();
    markMessagesAsRead(); // 페이지 로드시 기존 메시지를 읽음 상태로 변경
    fetchOtherUserData(); // 페이지 로드시 상대방의 이름과 프로필 이미지를 가져옴
  }

  Future<void> fetchOtherUserData() async {
    final userDoc = await _firestore.collection('users').doc(widget.otherUserId).get();
    if (userDoc.exists) {
      setState(() {
        otherUserName = userDoc['nickname'] ?? 'Unknown';
        otherUserProfileImage = userDoc['profile_image'];
        otherName = userDoc['name'] ?? 'Unknown';
      });
    }
  }

  void markMessagesAsRead() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final unreadMessages = await _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .where('senderId', isEqualTo: widget.otherUserId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in unreadMessages.docs) {
      doc.reference.update({'isRead': true});
    }
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final customMessageId = "${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}";

      // _controller.text 값을 임시 변수에 저장
      final String messageText = _controller.text;

      // 입력 필드를 즉시 초기화
      _controller.clear();

      // Firestore에 메시지 저장
      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc(customMessageId)
          .set({
        'messageId': customMessageId,
        'senderId': currentUser.uid,
        'senderName': currentUser.displayName ?? 'Unknown',
        'message': messageText, // 임시 변수에 저장한 메시지 사용
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // 마지막 메시지 업데이트
      await _firestore.collection('chats').doc(widget.chatId).update({
        'lastMessage': messageText, // 임시 변수에 저장한 메시지 사용
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "$otherName님과의 채팅방",
          style: const TextStyle(color: Colors.black),
        ),
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                markMessagesAsRead();

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index];
                    final message = messageData['message'];
                    final senderId = messageData['senderId'];
                    final timestamp = messageData['timestamp'] as Timestamp?;
                    final isRead = messageData['isRead'] ?? false;
                    final isCurrentUser = senderId == _auth.currentUser!.uid;

                    String messageDate = '';
                    if (timestamp != null) {
                      final date = timestamp.toDate();
                      messageDate = DateFormat('yyyy년 M월 d일').format(date);
                    }

                    bool showDate = false;
                    if (index == messages.length - 1 ||
                        DateFormat('yyyy년 M월 d일').format(
                            (messages[index + 1]['timestamp'] as Timestamp).toDate()) !=
                            messageDate &&
                            messageDate != '') {
                      showDate = true;
                    }

                    return Column(
                      crossAxisAlignment: isCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (showDate)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey[400],
                                    thickness: 0.5,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    messageDate,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey[400],
                                    thickness: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Row(
                          mainAxisAlignment: isCurrentUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (isCurrentUser && !isRead)
                              Padding(
                                padding: const EdgeInsets.only(right: 0.0),
                                child: Text(
                                  '1',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            if (!isCurrentUser)
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0, right: 0.0),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: otherUserProfileImage != null &&
                                          otherUserProfileImage!.isNotEmpty
                                          ? NetworkImage(otherUserProfileImage!)
                                          : AssetImage('assets/default_profile.png')
                                      as ImageProvider,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      otherUserName,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            Flexible(
                              child: FractionallySizedBox(
                                widthFactor: 0.6, // 너비를 화면의 60%로 제한
                                alignment: isCurrentUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: isCurrentUser
                                        ? Colors.blue[100]
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(12),
                                      topRight: const Radius.circular(12),
                                      bottomLeft: isCurrentUser
                                          ? const Radius.circular(12)
                                          : const Radius.circular(0),
                                      bottomRight: isCurrentUser
                                          ? const Radius.circular(0)
                                          : const Radius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    message,
                                    style: TextStyle(
                                      color: isCurrentUser
                                          ? Colors.blue[900]
                                          : Colors.black,
                                    ),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요...',
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
