// import 'package:flutter/cupertino.dart'; // Cupertino 디자인 요소를 사용하기 위한 패키지
// import 'package:flutter/material.dart';  // Material 디자인 요소를 사용하기 위한 패키지
//
// class PostListPage extends StatelessWidget {  // StatelessWidget을 상속받은 MyApp 클래스 정의
//   const PostListPage({super.key});  // const 생성자, key는 위젯의 고유 식별자로 사용
//
//   @override
//   Widget build(BuildContext context) {  // 화면을 빌드하는 함수
//     return MaterialApp(  // MaterialApp을 반환하여 앱의 기본 테마와 설정을 정의
//       home: RecruitmentPage(),  // 앱의 시작 페이지를 RecruitmentPage로 설정
//     );
//   }
// }
//
// class RecruitmentPage extends StatelessWidget {  // 모집 게시물 페이지를 위한 StatelessWidget 정의
//   @override
//   Widget build(BuildContext context) {  // 화면을 빌드하는 함수
//     return Scaffold(  // 화면의 기본 구조를 만드는 Scaffold 위젯
//       appBar: AppBar(  // 상단에 앱바를 추가
//         title: Text('모집 게시물'),  // 앱바의 제목을 '모집 게시물'로 설정
//         centerTitle: true,  // 제목을 가운데 정렬
//         actions: [  // 앱바에 추가 기능 아이콘을 배치할 actions 배열
//           IconButton(  // 필터 버튼을 위한 IconButton 추가
//             icon: Icon(Icons.filter_list),  // 필터 아이콘 설정
//             onPressed: () {  // 버튼이 눌렸을 때 실행될 콜백 함수
//               // 필터 버튼 기능
//             },
//           ),
//         ],
//       ),
//       body: ListView.builder(  // 리스트 형태로 여러 아이템을 표시할 ListView.builder 위젯
//         itemCount: 4,  // 리스트 아이템의 개수를 4로 설정
//
//         itemBuilder: (context, index) {  // 리스트의 각 아이템을 빌드하는 함수
//           return Card(  // 각 리스트 아이템을 감싸는 Card 위젯
//             margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),  // 카드의 외부 여백 설정
//             child: ListTile(  // 카드 내의 내용 구성을 위한 ListTile 위젯
//               leading: Container(  // 왼쪽에 이미지를 배치할 컨테이너
//                 width: 50.0,  // 이미지 컨테이너의 너비
//                 height: 50.0,  // 이미지 컨테이너의 높이
//                 color: Colors.grey[300],  // 배경색을 회색으로 설정
//                 child: Icon(Icons.image, color: Colors.white),  // 흰색 이미지 아이콘 추가
//               ),
//               title: Text('스터디원 모집'),  // 항목의 제목을 '스터디원 모집'으로 설정
//               subtitle: Column(  // 여러 줄의 설명을 표시하기 위해 Column 위젯 사용
//                 crossAxisAlignment: CrossAxisAlignment.start,  // 텍스트를 왼쪽 정렬
//                 children: [
//                   Text('공부 열심히 하실분 구해요'),  // 첫 번째 설명 텍스트
//                   Text('10월 15일 17시 선정 예정'),  // 두 번째 설명 텍스트
//                   Text('참여인원 1/6'),  // 세 번째 설명 텍스트
//                 ],
//               ),
//               trailing: IconButton(  // 오른쪽에 위치한 좋아요 버튼
//                 icon: Icon(Icons.favorite_border),  // 좋아요를 나타내는 아이콘 설정
//                 onPressed: () {  // 버튼을 눌렀을 때 호출되는 콜백 함수
//                   // 좋아요 버튼 기능
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//       bottomNavigationBar: BottomNavigationBar(  // 하단에 네비게이션 바 추가
//         items: [  // 네비게이션 바에 표시할 아이템들
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),  // 첫 번째 아이템: 홈
//           BottomNavigationBarItem(icon: Icon(Icons.chat), label: '채팅'),  // 두 번째 아이템: 채팅
//           BottomNavigationBarItem(icon: Icon(Icons.post_add), label: '게시물'),  // 세 번째 아이템: 게시물
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),  // 네 번째 아이템: 프로필
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(  // 화면 하단에 떠 있는 글 작성 버튼
//         onPressed: () {  // 버튼을 눌렀을 때 호출되는 콜백 함수
//           // 글 작성 버튼 기능
//         },
//         child: Icon(Icons.edit),  // 연필 모양의 아이콘을 버튼에 추가
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/post.dart';

// 게시물 리스트 페이지
class PostListPage extends StatelessWidget {
  // 생성자 정의
  PostListPage({super.key});

  //----------------------------------------------------------------------------------------------------------- Firestore에 샘플 데이터를 추가하는 함수
  void addSampleDataToFirestore() {
    final collection = FirebaseFirestore.instance.collection('posts');

    final samplePosts = [
      Post(
        id: '1',
        title: '스터디 그룹 모집',
        content: '열심히 공부할 스터디원들을 모집합니다!',
        tag: '서울',
        createdAt: DateTime.now(),
        recruit: 5,
        imageUrl: 'https://via.placeholder.com/150'
      ),
      Post(
        id: '2',
        title: '축구 동호회 모집',
        content: '매주 주말에 축구하실 분들을 구합니다.',
        tag: '부산',
        createdAt: DateTime.now(),
        recruit: 10,
        imageUrl: 'https://randomuser.me/api/portraits/men/1.jpg'
      ),
      Post(
        id: '3',
        title: '영화 동아리',
        content: '영화 감상을 좋아하는 분들 모여주세요!',
        tag: '대전',
        createdAt: DateTime.now(),
        recruit: 8,
        imageUrl: 'https://source.unsplash.com/random/300x200'
      ),
      Post(
        id: '4',
        title: '등산 동호회',
        content: '산을 좋아하시는 분들 함께해요.',
        tag: '강원',
        createdAt: DateTime.now(),
        recruit: 7,
        imageUrl: 'https://source.unsplash.com/random/300x200?hiking',
      ),
      Post(
        id: '5',
        title: '요가 모임',
        content: '함께 요가를 즐길 분들 모집합니다.',
        tag: '인천',
        createdAt: DateTime.now(),
        recruit: 6,
        imageUrl: 'https://source.unsplash.com/random/300x200?yoga',
      ),
      Post(
        id: '6',
        title: '프로그래밍 스터디',
        content: '프로그래밍에 관심 있는 분들 환영합니다!',
        tag: '서울',
        createdAt: DateTime.now(),
        recruit: 4,
        imageUrl: 'https://source.unsplash.com/random/300x200?programming',
      ),
      Post(
        id: '7',
        title: '독서 모임',
        content: '다양한 책을 함께 읽어요!',
        tag: '대구',
        createdAt: DateTime.now(),
        recruit: 12,
        imageUrl: 'https://source.unsplash.com/random/300x200?reading',
      ),
      Post(
        id: '8',
        title: '사진 촬영 모임',
        content: '사진 촬영을 좋아하시는 분들 모여요!',
        tag: '광주',
        createdAt: DateTime.now(),
        recruit: 5,
        imageUrl: 'https://source.unsplash.com/random/300x200?photography',
      ),
      Post(
        id: '9',
        title: '여행 동호회',
        content: '국내외 여행을 함께할 분들을 찾습니다!',
        tag: '부산',
        createdAt: DateTime.now(),
        recruit: 15,
        imageUrl: 'https://source.unsplash.com/random/300x200?travel',
      ),
      Post(
        id: '10',
        title: '요리 모임',
        content: '다양한 요리를 함께 만들어봐요!',
        tag: '서울',
        createdAt: DateTime.now(),
        recruit: 6,
        imageUrl: 'https://source.unsplash.com/random/300x200?cooking',
      ),
      Post(
        id: '11',
        title: '악기 연주 모임',
        content: '다양한 악기를 연주하실 분들 모여주세요!',
        tag: '대전',
        createdAt: DateTime.now(),
        recruit: 10,
        imageUrl: 'https://source.unsplash.com/random/300x200?music',
      ),
    ];

    for (var post in samplePosts) {
      collection.doc(post.id).set(post.toJson());
    }
  }
  //----------------------------------------------------------------------------------------------------------- Firestore에 샘플 데이터를 추가하는 함수


  // Firestore에서 'posts' 컬렉션의 데이터를 스트림 형태로 가져오는 변수
  final Stream<QuerySnapshot<Post>> postsStream = FirebaseFirestore.instance
      .collection('posts')  // 'posts' 컬렉션을 선택
      .withConverter<Post>(  // Firestore 데이터를 Post 객체로 변환
    fromFirestore: (snapshot, _) => Post.fromJson(snapshot.data()!),  // Firestore의 JSON 데이터를 Post 객체로 변환
    toFirestore: (post, _) => post.toJson(),  // Post 객체를 Firestore에 JSON 형식으로 변환하여 저장
  )
      .snapshots();  // 실시간으로 데이터 변화를 스트림 형태로 제공

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(  // 상단에 고정된 앱바(AppBar) 위젯
        title: Text('모집 게시물'),  // 앱바의 제목을 '모집 게시물'로 설정
        centerTitle: true,  // 제목을 가운데 정렬
      ),
      body: StreamBuilder<QuerySnapshot<Post>>(  // Firestore의 스트림 데이터를 감시하여 UI를 업데이트하는 StreamBuilder
        stream: postsStream,  // postsStream 스트림을 연결하여 데이터 변화를 감시
        builder: (context, snapshot) {
          if (snapshot.hasError) { //firebase연결이 안되어있는경우
            return Center(child: Text('Firestore 연결 오류 발생'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // 데이터 로딩 중일 때 로딩 스피너를 화면 중앙에 표시
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('게시물이 없습니다.')); // 데이터가 없을 때 "게시물이 없습니다." 메시지를 화면 중앙에 표시
          }

          // Firestore에서 데이터를 성공적으로 가져왔을 때
          final posts = snapshot.data!.docs.map((doc) => doc.data()).toList();  // 각 문서를 Post 객체로 변환하여 리스트로 저장

          return ListView.builder(  // 리스트 형태로 게시물을 표시하는 ListView.builder
            itemCount: posts.length,  // 리스트 아이템 개수를 posts 리스트 길이로 설정
            itemBuilder: (context, index) {
              final post = posts[index];  // 현재 인덱스의 Post 객체

              return Card(  // 게시물 항목을 Card 위젯으로 감싸서 디자인 적용
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),  // 카드의 상하, 좌우 여백 설정
                child: ListTile(  // Card 내부에 텍스트와 아이콘을 표시하는 ListTile 위젯

                //   leading: Container(  // 왼쪽에 위치한 이미지나 아이콘을 위한 컨테이너
                //   width: 50.0,  // 컨테이너 너비
                //   height: 50.0,  // 컨테이너 높이
                //   color: Colors.grey[300],  // 배경 색상을 회색으로 설정
                //   child: Icon(Icons.image, color: Colors.white),  // 흰색 아이콘을 추가하여 이미지 대체
                // ),
                  leading: Container(  // 왼쪽에 위치한 이미지나 아이콘을 위한 컨테이너
                    width: 50.0,  // 컨테이너 너비
                    height: 50.0,  // 컨테이너 높이
                    color: Colors.grey[300],  // 배경 색상을 회색으로 설정
                    child: post.imageUrl != null  // imageUrl이 있는지 확인
                        ? Image.network(  // imageUrl이 있으면 해당 URL에서 이미지 불러오기
                      post.imageUrl!,
                      fit: BoxFit.cover,  // 이미지가 컨테이너에 맞도록 설정
                    )
                        : Icon(Icons.image, color: Colors.white),  // imageUrl이 없으면 기본 아이콘 표시
                  ),

                  title: Text(post.title),  // Firestore에서 가져온 게시물 제목을 표시
                  subtitle: Column(  // 여러 줄로 설명을 표시하기 위해 Column 사용
                    crossAxisAlignment: CrossAxisAlignment.start,  // 텍스트를 왼쪽 정렬
                    children: [
                      Text(post.content), // 게시물 내용을 표시
                      Text('지역: ${post.tag}'), // 태그를 지역으로 표시
                      Text('모집인원 ${post.recruit}'), // 모집 인원 표시 (예시, 실제 데이터에 맞게 수정 가능)
                    ],
                  ),
                  trailing: IconButton(  // 오른쪽에 위치한 좋아요 버튼
                    icon: Icon(Icons.favorite_border),  // 좋아요를 나타내는 아이콘
                    onPressed: () {  // 버튼 클릭 시 호출되는 콜백 함수
                      // 좋아요 기능 구현 (추후 기능 추가 가능)
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(  // 하단에 위치한 글 작성 버튼
        onPressed: () {  // 버튼 클릭 시 호출되는 콜백 함수
          addSampleDataToFirestore();  // 버튼이 눌릴 때 Firestore에 샘플 데이터를 추가
        },
        child: Icon(Icons.edit),  // 버튼 아이콘으로 연필 모양 추가
      ),

    );
  }
}



