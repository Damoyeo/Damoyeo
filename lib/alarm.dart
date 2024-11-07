import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 앱이 백그라운드 또는 종료된 상태에서 알림을 수신했을 때 실행되는 핸들러
  await Firebase.initializeApp();
  print("백그라운드에서 알림 수신: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 백그라운드에서 알림을 수신할 때의 핸들러 설정
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NotificationTestScreen(),
    );
  }
}

class NotificationTestScreen extends StatefulWidget {
  @override
  _NotificationTestScreenState createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  // FCM 초기화 및 알림 권한 요청
  void _initializeFCM() async {
    // iOS의 경우 알림 권한 요청
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('사용자가 알림 권한을 허용함');
    } else {
      print('사용자가 알림 권한을 허용하지 않음');
    }

    // FCM 토큰 출력 (테스트용으로 출력해 백엔드에서 특정 기기로 전송 가능)
    String? token = await _firebaseMessaging.getToken();
    print("FCM 토큰: $token");

    // 앱이 포그라운드에 있을 때 알림 수신
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('포그라운드에서 알림 수신: ${message.notification?.title}');
      print('알림 내용: ${message.notification?.body}');
      _showNotificationSnackBar(message.notification?.title, message.notification?.body);
    });

    // 앱이 백그라운드 상태에서 알림을 클릭했을 때
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('백그라운드에서 알림 클릭으로 앱 열림');
      _showNotificationSnackBar(message.notification?.title, message.notification?.body);
    });

    // 앱이 종료된 상태에서 알림을 클릭했을 때
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('앱이 종료된 상태에서 알림 클릭으로 앱 열림');
        _showNotificationSnackBar(message.notification?.title, message.notification?.body);
      }
    });
  }

  // 알림 내용을 스낵바로 표시하는 함수
  void _showNotificationSnackBar(String? title, String? body) {
    final snackBar = SnackBar(
      content: Text("$title\n$body"),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FCM Notification Test")),
      body: const Center(
        child: Text("Push notifications will appear as snackbar when received."),
      ),
    );
  }
}
