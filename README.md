# 고급 모바일 프로그래밍 프로젝트 "다모여"

![Language](https://img.shields.io/badge/language-Dart-blue)  
![Firebase](https://img.shields.io/badge/Firebase-%23039BE5.svg?&logo=firebase&logoColor=white)

## 소개

**다모여**는 Flutter와 firebase 기반의 모든 기기에서 일관된 디자인을 제공하는 모바일 애플리케이션입니다. 
사용자는 모집 게시글 작성을 통해 사람을 모으고 다양한 관심사 게시글에 참여하여 편리하게 팀을 구성할 수 있습니다.


### 기술 스택
**다모여**는 최신 기술을 활용해 안정적이고 효율적인 사용자 경험을 제공합니다.
- **Flutter:** Android와 iOS 모두에서 일관된 디자인과 성능 제공
- **Firebase:** 
  - 사용자 인증 (Firebase Authentication)
  - 데이터 저장 및 관리 (Firestore Database)
  - 파일 업로드 및 저장 (Firebase Storage)
- **Google Maps 연동:** 활동 장소를 지도 상에서 쉽게 확인 가능

**다모여**는 새로운 친구를 만나고, 팀을 꾸리고, 이벤트를 만들어가는 과정을 쉽고 즐겁게 만들어줍니다.  
함께 더 많은 것을 이루기 위해 **다모여**에서 시작하세요!  

---

## 팀원 소개

| 김소룡 | 이종범 | 송진우 | 박진호 |

---

## 구현 상태

✨ **일관된 디자인**  
Flutter를 사용하여 Android 및 iOS 환경에서 일관된 사용자 경험 제공.

---

## 주요 기능

### ✨ 회원가입 및 로그인
- **회원가입:** 사용자가 이메일, 비밀번호, 이름, 닉네임을 입력하여 계정을 생성할 수 있습니다.
- **로그인:** 생성된 계정 정보를 통해 사용자는 로그인하여 서비스를 이용할 수 있습니다.

---

### ✨ 모집 게시글 리스트
- **게시글 조회:** 이전에 작성된 모집 게시글 리스트를 확인할 수 있습니다.
- **정렬 기능:** 
  - 최신순/오래된순
  - 제목 가나다순/역순
- **필터 기능:** 
  - 관심 있는 카테고리(친목, 스포츠, 스터디, 여행, 알바 등)로 게시글 리스트를 필터링하여 볼 수 있습니다.
- **좋아요 기능:** 사용자가 관심 있는 게시글을 찜하여 따로 모아볼 수 있습니다.

---

### ✨ 모집 게시글 작성
- **게시글 작성:** 
  - 글 제목, 카테고리, 모집 인원, 예상 활동 금액, 불참 횟수 제한, 모집 글 내용을 입력하여 작성 가능.
  - 활동 장소 입력 및 사진 첨부(최대 10장)를 통해 모임 정보를 효과적으로 전달.
- **작성 완료 후 게시:** 게시글은 모집 게시글 리스트에 표시됩니다.

---

### ✨ 모집 게시글 상세 보기
- **모집 정보 확인:** 
  - 제목, 작성자, 날짜 및 시간, 활동 장소, 예상 금액, 참가 가능 인원을 포함한 상세 정보 확인.
- **참여 신청:** 모집 게시글에 참가 의사를 등록할 수 있습니다.
- **참여 취소:** 등록된 참여 의사를 취소할 수 있습니다.
- **좋아요:** 해당 게시글을 찜하여 찜 목록에 추가.

---

### ✨ 채팅 기능
- **1:1 채팅:** 모집 글 작성자와 지원자 간 1:1 채팅 가능.
- **채팅 목록:** 사용자가 참여 중인 채팅방 목록을 확인할 수 있습니다.
- **채팅방 고정 및 나가기:** 중요 채팅방을 상단 고정하거나 나가기 가능.

---

### ✨ 활동 내역
- **내 모집:** 사용자가 작성한 모집 글 목록을 확인할 수 있습니다.
- **참가한 모집:** 사용자가 참여 중인 모집 글 목록을 확인할 수 있습니다.

---

### ✨ 프로필 관리
- **내 정보 수정:** 사용자의 프로필 이미지, 닉네임, 전화번호 등 정보를 수정할 수 있습니다.
- **비밀번호 변경:** 기존 비밀번호를 통해 새 비밀번호로 변경 가능합니다.

---

### ✨ 기타
- **UI/UX:** 직관적이고 깔끔한 UI로 누구나 쉽게 이용 가능.
- **데이터 관리:** 게시글 및 유저 정보를 안전하게 관리하고 업데이트.

---

## 설치

### 요구사항
- Flutter SDK: 2.17.0 이상 < 3.0.0
- Android Studio

### 설치 방법

1. **Flutter 환경 설정**
   - 프로젝트 루트의 `local.properties` 파일에 Flutter SDK 경로를 추가하세요.
     ```plaintext
     flutter.sdk=YOUR_FLUTTER_SDK_PATH
     ```

2. **의존성 설치**
   - 아래 명령어를 실행하여 `pubspec.yaml` 파일에 정의된 의존성을 설치하세요:
     ```bash
     flutter pub get
     ```

   #### 주요 의존성 및 다운로드 주소
   - **Firebase 관련**
     - [`firebase_core`](https://pub.dev/packages/firebase_core): Firebase 초기화
     - [`firebase_auth`](https://pub.dev/packages/firebase_auth): Firebase 인증
     - [`cloud_firestore`](https://pub.dev/packages/cloud_firestore): Firestore 데이터베이스
     - [`firebase_storage`](https://pub.dev/packages/firebase_storage): Firebase 파일 저장소
     - [`firebase_messaging`](https://pub.dev/packages/firebase_messaging): 푸시 알림
   - **Flutter 관련**
     - [`image_picker`](https://pub.dev/packages/image_picker): 이미지 선택
     - [`flutter_datetime_picker`](https://pub.dev/packages/flutter_datetime_picker): 날짜 및 시간 선택기
   - **기타**
     - [`google_maps_flutter`](https://pub.dev/packages/google_maps_flutter): Google Maps 연동
     - [`cached_network_image`](https://pub.dev/packages/cached_network_image): 캐시된 이미지 처리

3. **Gradle 설정**
   - Firebase 서비스를 활성화하기 위해 `google-services.json` 파일을 `android/app/` 디렉토리에 추가하세요.

4. **Android Studio 실행**
   - `Run` 버튼을 클릭하거나 터미널에서 아래 명령어 실행:
     ```bash
     flutter run
     ```

--- 

## 파일 트리구조
```
lib
├─ alarm.dart
├─ auth
│  └─ auth_gate.dart
├─ create
│  ├─ create_model.dart
│  └─ create_page.dart
├─ firebase_options.dart
├─ login
│  ├─ AdditionalInfoScreen.dart
│  └─ login_screen.dart
├─ main.dart
├─ models
│  ├─ create_model.dart
│  └─ post.dart
├─ post
│  ├─ create_post.dart
│  └─ post_detail.dart
├─ sample.dart
└─ tab
   ├─ account
   │  ├─ account_page.dart
   │  ├─ EditPassword_page.dart
   │  └─ EditProfilePage.dart
   ├─ chat
   │  ├─ chat_detail_page.dart
   │  └─ chat_page.dart
   ├─ favorite
   │  └─ favorite_page.dart
   ├─ home
   │  └─ home_page.dart
   ├─ myActivity
   │  └─ MyActivity_page.dart
   ├─ postList
   │  ├─ postList_model.dart
   │  └─ postList_page.dart
   ├─ search
   │  └─ search_page.dart
   └─ tab_page.dart
```
