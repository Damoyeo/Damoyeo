import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// ChatDetailPage: 특정 채팅방의 대화 내용을 표시하는 화면을 구성하는 Stateful 위젯
class ChatDetailPage extends StatefulWidget {
  final String chatId; // 채팅방 ID
  final String otherUserId; // 상대방 사용자 ID

  // ChatDetailPage 생성자
  const ChatDetailPage({
    Key? key,
    required this.chatId, // 채팅방 ID 필수
    required this.otherUserId, // 상대방 사용자 ID 필수
  }) : super(key: key);

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _controller = TextEditingController(); // 입력 필드 제어용 컨트롤러
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase 인증 객체
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore 데이터베이스 객체

  @override
  void initState() {
    super.initState();
    markMessagesAsRead(); // 페이지 로드시 기존 메시지를 읽음 상태로 변경
  }

  // markMessagesAsRead: 상대방이 보낸 읽지 않은 메시지를 읽음 상태로 변경하는 함수
  void markMessagesAsRead() async {
    final currentUser = _auth.currentUser; // 현재 로그인한 사용자 가져오기
    if (currentUser == null) return; // 로그인하지 않은 경우 함수 종료

    // Firestore에서 상대방이 보낸 읽지 않은 메시지들을 조회
    final unreadMessages = await _firestore
        .collection('chats') // 'chats' 컬렉션에서
        .doc(widget.chatId) // 특정 채팅방 문서 접근
        .collection('messages') // 메시지 하위 컬렉션 접근
        .where('senderId', isEqualTo: widget.otherUserId) // 상대방이 보낸 메시지만 필터링
        .where('isRead', isEqualTo: false) // 읽지 않은 메시지만 필터링
        .get();

    // 조회된 각 메시지를 읽음 상태로 업데이트
    for (var doc in unreadMessages.docs) {
      doc.reference.update({'isRead': true}); // 'isRead' 필드를 true로 설정
    }
  }

  // _sendMessage: 새로운 메시지를 Firestore에 저장하는 함수
  void _sendMessage() async {
    if (_controller.text.isNotEmpty) { // 입력 필드가 비어있지 않을 때만 실행
      final currentUser = _auth.currentUser; // 현재 사용자 가져오기
      if (currentUser == null) return; // 사용자가 없는 경우 종료

      // 고유 메시지 ID 생성 (사용자 ID와 현재 시간 기반)
      final customMessageId = "${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}";

      // Firestore에 메시지 저장
      await _firestore
          .collection('chats') // 'chats' 컬렉션 접근
          .doc(widget.chatId) // 특정 채팅방 문서 접근
          .collection('messages') // 메시지 하위 컬렉션 접근
          .doc(customMessageId) // 생성한 메시지 ID로 문서 참조
          .set({
        'messageId': customMessageId, // 메시지 ID
        'senderId': currentUser.uid, // 현재 사용자 ID
        'senderName': currentUser.displayName ?? 'Unknown', // 사용자 이름
        'message': _controller.text, // 메시지 내용
        'timestamp': FieldValue.serverTimestamp(), // Firestore 서버 타임스탬프
        'isRead': false, // 새 메시지는 기본적으로 읽지 않은 상태
      });

      // 채팅방 문서에 마지막 메시지 내용과 시간 업데이트
      await _firestore.collection('chats').doc(widget.chatId).update({
        'lastMessage': _controller.text, // 마지막 메시지 내용
        'timestamp': FieldValue.serverTimestamp(), // 마지막 메시지 시간
      });

      _controller.clear(); // 입력 필드 초기화
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar 배경 색상 설정
        iconTheme: const IconThemeData(color: Colors.black), // 아이콘 색상 설정
        title: Text(
          "${widget.otherUserId}님과의 채팅방", // AppBar 제목에 상대방 ID 표시
          style: const TextStyle(color: Colors.black), // 텍스트 색상 설정
        ),
        elevation: 1, // AppBar 그림자 높이
      ),
      backgroundColor: Colors.white, // Scaffold의 배경색
      body: Column(
        children: [
          Expanded(
            // StreamBuilder를 사용하여 실시간으로 Firestore의 메시지를 가져옴
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true) // 최신 메시지부터 정렬
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) { // 데이터가 없을 때 로딩 표시
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs; // 메시지 목록 저장

                // 새로운 메시지가 수신될 때마다 읽음 상태로 업데이트
                markMessagesAsRead();

                return ListView.builder(
                  reverse: true, // 메시지를 최신순으로 표시
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index];
                    final message = messageData['message']; // 메시지 내용
                    final senderId = messageData['senderId']; // 보낸 사람 ID
                    final timestamp = messageData['timestamp'] as Timestamp?; // 타임스탬프
                    final isRead = messageData['isRead'] ?? false; // 읽음 여부
                    final isCurrentUser = senderId == _auth.currentUser!.uid; // 메시지 발신자가 현재 사용자 여부 확인

                    // 타임스탬프를 'yyyy년 M월 d일' 형식으로 변환
                    String messageDate = '';
                    if (timestamp != null) {
                      final date = timestamp.toDate();
                      messageDate = DateFormat('yyyy년 M월 d일').format(date);
                    }

                    // 현재 메시지의 날짜가 이전 메시지와 다를 때만 날짜 표시
                    bool showDate = false;
                    if (index == messages.length - 1 ||
                        DateFormat('yyyy년 M월 d일').format(
                            (messages[index + 1]['timestamp'] as Timestamp).toDate()) !=
                            messageDate) {
                      showDate = true;
                    }

                    return Column(
                      crossAxisAlignment: isCurrentUser
                          ? CrossAxisAlignment.end // 현재 사용자가 보낸 경우 오른쪽 정렬
                          : CrossAxisAlignment.start, // 상대방이 보낸 경우 왼쪽 정렬
                      children: [
                        if (showDate) // 날짜가 다른 경우에만 날짜를 표시
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey[400], // 날짜 선 색상
                                    thickness: 0.5, // 선 두께
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    messageDate, // 날짜 텍스트
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
                              ? MainAxisAlignment.end // 현재 사용자가 보낸 메시지는 오른쪽 정렬
                              : MainAxisAlignment.start, // 상대방이 보낸 메시지는 왼쪽 정렬
                          children: [
                            if (isCurrentUser && !isRead) // 읽지 않은 메시지 표시
                              Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: Text(
                                  '1', // 읽지 않은 메시지 표시
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            Align(
                              alignment: isCurrentUser
                                  ? Alignment.centerRight // 현재 사용자 메시지는 오른쪽 정렬
                                  : Alignment.centerLeft, // 상대방 메시지는 왼쪽 정렬
                              child: Container(
                                padding: const EdgeInsets.all(12), // 메시지 패딩
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10), // 메시지 여백
                                decoration: BoxDecoration(
                                  color: isCurrentUser
                                      ? Colors.blue[100] // 현재 사용자 메시지 배경색
                                      : Colors.grey[300], // 상대방 메시지 배경색
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
                                  message, // 메시지 텍스트
                                  style: TextStyle(
                                    color: isCurrentUser ? Colors.blue[900] : Colors.black,
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
            padding: const EdgeInsets.all(8.0), // 메시지 입력 필드 여백
            child: Row(
              children: [
                Expanded(
                  // 메시지 입력 필드
                  child: TextField(
                    controller: _controller, // 메시지 입력 제어용 컨트롤러
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요...', // 플레이스홀더 텍스트
                      filled: true,
                      fillColor: Colors.grey[200], // 입력 필드 배경색
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0), // 내부 여백
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24), // 필드 테두리 둥글기
                        borderSide: BorderSide.none, // 테두리 제거
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8), // 전송 버튼과의 간격
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue), // 전송 버튼 아이콘과 색상
                  onPressed: _sendMessage, // 메시지 전송 함수 호출
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}