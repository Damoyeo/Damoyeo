import 'package:flutter/cupertino.dart'; // Cupertino 디자인 요소를 사용하기 위한 패키지
import 'package:flutter/material.dart';  // Material 디자인 요소를 사용하기 위한 패키지

class PostListPage extends StatelessWidget {  // StatelessWidget을 상속받은 MyApp 클래스 정의
  const PostListPage({super.key});  // const 생성자, key는 위젯의 고유 식별자로 사용

  @override
  Widget build(BuildContext context) {  // 화면을 빌드하는 함수
    return MaterialApp(  // MaterialApp을 반환하여 앱의 기본 테마와 설정을 정의
      home: RecruitmentPage(),  // 앱의 시작 페이지를 RecruitmentPage로 설정
    );
  }
}

class RecruitmentPage extends StatelessWidget {  // 모집 게시물 페이지를 위한 StatelessWidget 정의
  @override
  Widget build(BuildContext context) {  // 화면을 빌드하는 함수
    return Scaffold(  // 화면의 기본 구조를 만드는 Scaffold 위젯
      appBar: AppBar(  // 상단에 앱바를 추가
        title: Text('모집 게시물'),  // 앱바의 제목을 '모집 게시물'로 설정
        centerTitle: true,  // 제목을 가운데 정렬
        actions: [  // 앱바에 추가 기능 아이콘을 배치할 actions 배열
          IconButton(  // 필터 버튼을 위한 IconButton 추가
            icon: Icon(Icons.filter_list),  // 필터 아이콘 설정
            onPressed: () {  // 버튼이 눌렸을 때 실행될 콜백 함수
              // 필터 버튼 기능
            },
          ),
        ],
      ),
      body: ListView.builder(  // 리스트 형태로 여러 아이템을 표시할 ListView.builder 위젯
        itemCount: 4,  // 리스트 아이템의 개수를 4로 설정

        itemBuilder: (context, index) {  // 리스트의 각 아이템을 빌드하는 함수
          return Card(  // 각 리스트 아이템을 감싸는 Card 위젯
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),  // 카드의 외부 여백 설정
            child: ListTile(  // 카드 내의 내용 구성을 위한 ListTile 위젯
              leading: Container(  // 왼쪽에 이미지를 배치할 컨테이너
                width: 50.0,  // 이미지 컨테이너의 너비
                height: 50.0,  // 이미지 컨테이너의 높이
                color: Colors.grey[300],  // 배경색을 회색으로 설정
                child: Icon(Icons.image, color: Colors.white),  // 흰색 이미지 아이콘 추가
              ),
              title: Text('스터디원 모집'),  // 항목의 제목을 '스터디원 모집'으로 설정
              subtitle: Column(  // 여러 줄의 설명을 표시하기 위해 Column 위젯 사용
                crossAxisAlignment: CrossAxisAlignment.start,  // 텍스트를 왼쪽 정렬
                children: [
                  Text('공부 열심히 하실분 구해요'),  // 첫 번째 설명 텍스트
                  Text('10월 15일 17시 선정 예정'),  // 두 번째 설명 텍스트
                  Text('참여인원 1/6'),  // 세 번째 설명 텍스트
                ],
              ),
              trailing: IconButton(  // 오른쪽에 위치한 좋아요 버튼
                icon: Icon(Icons.favorite_border),  // 좋아요를 나타내는 아이콘 설정
                onPressed: () {  // 버튼을 눌렀을 때 호출되는 콜백 함수
                  // 좋아요 버튼 기능
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(  // 하단에 네비게이션 바 추가
        items: [  // 네비게이션 바에 표시할 아이템들
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),  // 첫 번째 아이템: 홈
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '채팅'),  // 두 번째 아이템: 채팅
          BottomNavigationBarItem(icon: Icon(Icons.post_add), label: '게시물'),  // 세 번째 아이템: 게시물
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),  // 네 번째 아이템: 프로필
        ],
      ),
      floatingActionButton: FloatingActionButton(  // 화면 하단에 떠 있는 글 작성 버튼
        onPressed: () {  // 버튼을 눌렀을 때 호출되는 콜백 함수
          // 글 작성 버튼 기능
        },
        child: Icon(Icons.edit),  // 연필 모양의 아이콘을 버튼에 추가
      ),
    );
  }
}
