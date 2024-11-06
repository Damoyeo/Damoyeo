import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;
  final String otherUserId;

  const ChatDetailPage({
    Key? key,
    required this.chatId,
    required this.otherUserId,
  }) : super(key: key);

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'senderId': currentUser.uid,
        'senderName': currentUser.displayName ?? 'Unknown',
        'message': _controller.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('chats').doc(widget.chatId).update({
        'lastMessage': _controller.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "${widget.otherUserId}님과의 채팅방",
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
                String? previousDate;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index];
                    final message = messageData['message'];
                    final senderId = messageData['senderId'];
                    final timestamp = messageData['timestamp'] as Timestamp?;
                    final isCurrentUser = senderId == _auth.currentUser!.uid;

                    // 날짜 포맷 설정
                    String messageDate = '';
                    if (timestamp != null) {
                      final date = timestamp.toDate();
                      messageDate = DateFormat('yyyy년 M월 d일').format(date);
                    }

                    // 날짜가 바뀔 때마다 날짜 표시
                    bool showDate = false;
                    if (messageDate != previousDate) {
                      showDate = true;
                      previousDate = messageDate;
                    }

                    return Column(
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
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
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
                        Align(
                          alignment: isCurrentUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
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
                                color: isCurrentUser ? Colors.blue[900] : Colors.black,
                              ),
                            ),
                          ),
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
