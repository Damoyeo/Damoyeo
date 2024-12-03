import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gomoph/models//create_model.dart';
import 'package:gomoph/models/post.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kpostal/kpostal.dart';
class CreatePost extends StatefulWidget {
  final Post? post;

  const CreatePost({super.key, this.post});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final model = new CreateModel();

  late TextEditingController _titleTextController;
  late TextEditingController _addressTextController;
  late TextEditingController _detailAddressTextController;
  late TextEditingController _costTextController;
  late TextEditingController _contentTextController;
  late TextEditingController _recruitTextController;

  // 숫자 포맷 설정 수정시 불러온값 확인할때 숫자로만뜨는것을 해결하기위해
  final formatter = NumberFormat.currency(locale: "ko_KR", symbol: "₩");

  @override
  void initState() {
    super.initState();

    // 기존 게시물 데이터로 초기화 (수정 모드)
    if (widget.post != null) {
      final post = widget.post!;
      _titleTextController = TextEditingController(text: post.title);
      _addressTextController = TextEditingController(text: post.address);
      _detailAddressTextController =
          TextEditingController(text: post.detailAddress);
      _costTextController = TextEditingController(text: formatter.format(int.parse(post.cost.toString())));
      _contentTextController = TextEditingController(text: post.content);
      _recruitTextController =
          TextEditingController(text: post.recruit.toString());
      _localSelectedValue = post.tag;
      _selectedCategoryIndex = categories.indexOf(post.category);
      _selectedDate = post.meetingTime;
      _images.addAll(post.imageUrls); // URL은 String으로 추가
    } else {
      // 작성 모드 초기화
      _titleTextController = TextEditingController();
      _addressTextController = TextEditingController();
      _detailAddressTextController = TextEditingController();
      _costTextController = TextEditingController();
      _contentTextController = TextEditingController();
      _recruitTextController = TextEditingController();
    }
  }

///////////////////////////////////////////////////////////////날짜 시간 입력받는 기능
  DateTime? _selectedDate;

  // 날짜와 시간 선택 함수
  Future<void> _pickDateTime(BuildContext context) async {
    // 날짜 선택
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // 시간 선택
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        // DateTime에 시간 설정
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
        print(_selectedDate);
      } else {
        // 시간을 선택하지 않은 경우, 날짜만 저장
        setState(() {
          _selectedDate = pickedDate;
        });
        print(_selectedDate);
      }
    }
  }

  // 날짜와 시간을 하나의 문자열로 형식화
  String _formatDateTime(DateTime? selectedDate) {
    if (selectedDate == null) {
      return '날짜를 선택해주세요.';
    }

    // 날짜를 "MM월 dd일 HH:mm" 형식으로 변환
    final DateFormat formatter = DateFormat('MM월 dd일 HH:mm');
    return formatter.format(selectedDate);
  }

  /////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////// firebase에 넣을 변수들, 컨트롤러들
  int? _selectedCategoryIndex; // 선택된 카테고리의 인덱스
  List<String> categories = [
    '친목',
    '스포츠',
    '스터디',
    '여행',
    '알바',
    '게임',
    '봉사',
    '헬스',
    '음악',
    '기타'
  ];
  String? _localSelectedValue; //지역 드롭다운버튼 값
  String? _limitSelectedValue; //불참 횟수 드롭다운버튼 값
  // final _titleTextController = TextEditingController(); //제목 컨트롤러
  // final _addressTextController = TextEditingController(); //활동장소 컨트롤러
  // final _detailAddressTextController = TextEditingController(); //상세주소 컨트롤러
  // final _costTextController = TextEditingController(); //예상 활동금액 컨트롤러
  // final _contentTextController = TextEditingController(); //게시글 내용 컨트롤러
  // final _recruitTextController = TextEditingController(); //모집인원 컨트롤러

  @override
  void dispose() {
    // TODO: implement dispose
    _titleTextController.dispose();
    _addressTextController.dispose();
    _detailAddressTextController.dispose();
    _costTextController.dispose();
    _contentTextController.dispose();
    _recruitTextController.dispose();
    super.dispose();
  }

  //////////////////////////////////////////////////////////

  //유효성 검사
  bool _isTitleValid = true;
  bool _isLocalSelectedValid = true;
  bool _isAddressValid = true;
  bool _isDetailAddressValid = true;
  bool _isCostValid = true;
  bool _isContentValid = true;
  bool _isSelectedValid = true;
  bool _isDateTimeValid = true;
  bool _isRecruitValid = true;

  void _validateFields() {
    setState(() {
      _isTitleValid = _titleTextController.text.isNotEmpty;
      _isLocalSelectedValid = _localSelectedValue != null;
      _isAddressValid = _addressTextController.text.isNotEmpty;
      _isDetailAddressValid = _detailAddressTextController.text.isNotEmpty;
      _isCostValid = _costTextController.text.isNotEmpty;
      _isContentValid = _contentTextController.text.isNotEmpty;
      _isSelectedValid = _selectedCategoryIndex != null;
      _isDateTimeValid = _selectedDate != null;
      _isRecruitValid = _recruitTextController.text.isNotEmpty;
    });
  }

  // 에러 border
  OutlineInputBorder customInputBorder(
      bool isValid, Color enabledColor, Color errorColor) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: isValid ? enabledColor : errorColor,
      ),
    );
  }

  //에러 메시지
  Widget buildErrorIndicator(bool isValid, String message) {
    if (isValid) return SizedBox.shrink(); // 유효할 경우 아무것도 표시하지 않음

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 20,
          ),
          SizedBox(width: 4),
          Text(
            message,
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ),
    );
  }

  final ImagePicker _picker = ImagePicker();
  List<dynamic?> _images = []; // 업로드된 이미지 목록

  Future<void> _pickImage(ImageSource source) async {
    if (_images.length >= 10) {
      // 이미 10개의 이미지가 있으면 알림을 표시하고 반환
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("이미지는 최대 10개까지 업로드할 수 있습니다.")),
      );
      return;
    }

    // source가 갤러리인 경우 여러 이미지를 선택, 아닌 경우 단일 이미지 촬영
    if (source == ImageSource.gallery) {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null) {
        setState(() {
          _images.addAll(images.take(10 - _images.length)); // 남은 개수만큼만 추가
        });
      }
    } else {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _images.add(image);
        });
      }
    }

    // final XFile? image = await _picker.pickImage(source: source);
    // if (image != null) {
    //   setState(() {
    //     _images.add(image);
    //   });
    // }
  }

  //XFile?을 File형태로 변환 하는 함수.
  // 이미지를 업로드하기위함 image.path이용하여 함수 사용하지않고해결해보기
  List<File> convertXFilesToFiles(List<XFile?> xFiles) {
    return xFiles
        .where((xfile) => xfile != null) // null 필터링
        .map((xfile) => File(xfile!.path))
        .toList();
  }

  // 입력된 값에서 포맷을 제거하고 숫자로 변환. db에 저장할때 숫자로 저장하기위함.
  int saveToDatabase() {
    String formattedText = _costTextController.text; // ₩ 1,000 같은 값
    String cleanedText =
        formattedText.replaceAll(RegExp(r'[^\d]'), ''); // 숫자만 남기기
    int amount = int.parse(cleanedText); // 숫자형으로 변환
    return amount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 기능 추가
          },
        ),
        title: Text('모집글 작성'),
        centerTitle: true, // 제목을 중앙에 배치
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Wrap(
                          children: [
                            ListTile(
                              leading: Icon(Icons.camera_alt),
                              title: Text('Take a photo'),
                              onTap: () {
                                // 사진 촬영 기능 추가
                                Navigator.pop(context);
                                _pickImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.photo_library),
                              title: Text('Choose from gallery'),
                              onTap: () {
                                // 갤러리에서 사진 선택 기능 추가
                                Navigator.pop(context);
                                _pickImage(ImageSource
                                    .gallery); // 갤러리에서 이미지 선택// 카메라에서 이미지 선택
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 24, color: Colors.blue),
                        SizedBox(height: 4),
                        Text("${_images.length}/10",
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _images.asMap().entries.map((entry) {
                        int index = entry.key;
                        var image = entry.value;
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: image is String
                                    ? Image.network(
                                        image,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(image!.path),
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _images.removeAt(index);
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white70,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('제목',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _titleTextController,
              decoration: InputDecoration(
                hintText: '제목',
                enabledBorder:
                    customInputBorder(_isTitleValid, Colors.grey, Colors.red),
                focusedBorder:
                    customInputBorder(_isTitleValid, Colors.blue, Colors.red),
                errorBorder: customInputBorder(
                    false, Colors.grey, Colors.red), // errorBorder는 항상 빨간색
              ),
              onChanged: (_) {
                if (!_isTitleValid) setState(() => _isTitleValid = true);
              },
            ),
            buildErrorIndicator(_isTitleValid, "제목을 입력해주세요."),
            SizedBox(height: 16),
            Text('모집 분야',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: List.generate(categories.length, (index) {
                return ChoiceChip(
                  label: Text(categories[index]),
                  selected: _selectedCategoryIndex == index,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedCategoryIndex = selected ? index : null;
                    });
                  },
                );
              }),
            ),
            buildErrorIndicator(_isSelectedValid, "모집분야를 선택해주세요."),
            SizedBox(height: 16),
            Text('지역',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _localSelectedValue,
              decoration: InputDecoration(
                enabledBorder: customInputBorder(
                    _isLocalSelectedValid, Colors.grey, Colors.red),
                focusedBorder: customInputBorder(
                    _isLocalSelectedValid, Colors.blue, Colors.red),
                errorBorder: customInputBorder(
                    false, Colors.grey, Colors.red), // errorBorder는 항상 빨간색
              ),
              hint: Text('지역을 선택해주세요.'),
              items: [
                "서울특별시",
                "부산광역시",
                "대구광역시",
                "인천광역시",
                "광주광역시",
                "대전광역시",
                "울산광역시",
                "세종특별자치시",
                "경기도",
                "강원도",
                "충청북도",
                "충청남도",
                "전라북도",
                "전라남도",
                "경상북도",
                "경상남도",
                "제주특별자치도"
              ]
                  .map((String value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _localSelectedValue = newValue;
                  _isLocalSelectedValid = true; // 선택된 값 업데이트
                });
              },
              menuMaxHeight: 250, // 드롭다운의 최대 높이 제한
            ),
            buildErrorIndicator(_isLocalSelectedValid, "지역을 선택해주세요."),
            SizedBox(height: 16),
            Text(
              '활동 장소',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addressTextController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: '기본주소',
                      enabledBorder: customInputBorder(
                          _isAddressValid, Colors.grey, Colors.red),
                      focusedBorder: customInputBorder(
                          _isAddressValid, Colors.blue, Colors.red),
                      errorBorder: customInputBorder(false, Colors.grey,
                          Colors.red), // errorBorder는 항상 빨간색
                    ),
                    onChanged: (_) {
                      if (!_isAddressValid)
                        setState(() => _isAddressValid = true);
                    },
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => KpostalView(
                          // useLocalServer: true,
                          // localPort: 1024,
                          // kakaoKey: '{Add your KAKAO DEVELOPERS JS KEY}',
                          callback: (Kpostal result) {
                            setState(() {
                              // 우편번호 코드 postCode = result.postCode;
                              _addressTextController.text = result.address;
                            });
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    '주소찾기',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
            buildErrorIndicator(_isAddressValid, "주소를 입력해주세요."),
            SizedBox(height: 8),
            TextField(
              controller: _detailAddressTextController,
              decoration: InputDecoration(
                hintText: '상세주소',
                enabledBorder: customInputBorder(
                    _isDetailAddressValid, Colors.grey, Colors.red),
                focusedBorder: customInputBorder(
                    _isDetailAddressValid, Colors.blue, Colors.red),
                errorBorder: customInputBorder(
                    false, Colors.grey, Colors.red), // errorBorder는 항상 빨간색
              ),
              onChanged: (_) {
                if (!_isDetailAddressValid)
                  setState(() => _isDetailAddressValid = true);
              },
            ),
            buildErrorIndicator(_isDetailAddressValid, "상세주소를 입력해주세요."),
            SizedBox(height: 16),
            Text(
              '날짜와 시간',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: _formatDateTime(_selectedDate),
                enabledBorder: customInputBorder(
                    _isDateTimeValid, Colors.grey, Colors.red),
                focusedBorder: customInputBorder(
                    _isDateTimeValid, Colors.blue, Colors.red),
                errorBorder: customInputBorder(false, Colors.grey, Colors.red),
                // errorBorder는 항상 빨간색
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                await _pickDateTime(context);
              },
            ),
            buildErrorIndicator(_isDateTimeValid, "날짜,시간을 입력해주세요."),
            SizedBox(height: 16),
            Text('모집 인원',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _recruitTextController,
              decoration: InputDecoration(
                hintText: '모집 인원을 입력해주세요.',
                enabledBorder:
                    customInputBorder(_isRecruitValid, Colors.grey, Colors.red),
                focusedBorder:
                    customInputBorder(_isRecruitValid, Colors.blue, Colors.red),
                errorBorder: customInputBorder(
                    false, Colors.grey, Colors.red), // errorBorder는 항상 빨간색
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) {
                if (!_isRecruitValid) setState(() => _isRecruitValid = true);
              },
            ),
            buildErrorIndicator(_isRecruitValid, "모집인원을 입력해주세요."),
            SizedBox(height: 16),
            Text('예상 활동 금액',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              inputFormatters: <TextInputFormatter>[
                CurrencyTextInputFormatter.currency(
                  locale: 'ko',
                  decimalDigits: 0,
                  name: '₩ ',
                )
              ],
              controller: _costTextController,
              decoration: InputDecoration(
                hintText: '₩ 활동금액을 입력해주세요.',
                enabledBorder:
                    customInputBorder(_isCostValid, Colors.grey, Colors.red),
                focusedBorder:
                    customInputBorder(_isCostValid, Colors.blue, Colors.red),
                errorBorder: customInputBorder(
                    false, Colors.grey, Colors.red), // errorBorder는 항상 빨간색
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) {
                if (!_isCostValid) setState(() => _isCostValid = true);
              },
            ),
            buildErrorIndicator(_isCostValid, "활동금액을 입력해주세요."),
            SizedBox(height: 16),
            Text('모집글 내용',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _contentTextController,
              decoration: InputDecoration(
                hintText: '모집글 내용을 작성해주세요.',
                enabledBorder:
                    customInputBorder(_isContentValid, Colors.grey, Colors.red),
                focusedBorder:
                    customInputBorder(_isContentValid, Colors.blue, Colors.red),
                errorBorder: customInputBorder(
                    false, Colors.grey, Colors.red), // errorBorder는 항상 빨간색
              ),
              maxLines: 3,
              onChanged: (_) {
                if (!_isContentValid) setState(() => _isContentValid = true);
              },
            ),
            buildErrorIndicator(_isContentValid, "모집글 내용을 입력해주세요."),
            SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: double.infinity, // 화면 너비에 맞춰서 버튼을 꽉 차게 설정
                child: ElevatedButton(
                  onPressed: () async {
                    List<String> stringImages = [];
                    List<XFile> xfileImages = [];

                    for (var image in _images) {
                      if (image is String) {
                        stringImages.add(image); // String 값 추가
                      } else if (image is XFile) {
                        xfileImages.add(image); // XFile 값 추가
                      }
                    }
                    _validateFields(); //상태 업데이트
                    // 작성 완료 기능 추가
                    if (_isLocalSelectedValid &&
                        _isTitleValid &&
                        _isContentValid &&
                        _isAddressValid &&
                        _isDetailAddressValid &&
                        _isCostValid &&
                        _isSelectedValid &&
                        _isDateTimeValid &&
                        _isRecruitValid) {
                      // 로딩 스피너 표시
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      );

                      try {
                        // 업로드 처리
                        if (widget.post == null) {
                          final userId = FirebaseAuth.instance.currentUser?.uid;
                          if (userId == null) {
                            throw Exception("사용자가 로그인되어 있지 않습니다.");
                          }

                          // Firestore에서 user_PostCount 가져오기
                          final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
                          final userSnapshot = await userDoc.get();

                          int currentPostCount = 0;
                          if (userSnapshot.exists && userSnapshot.data()!.containsKey('user_PostCount')) {
                            currentPostCount = userSnapshot['user_PostCount'];
                          }

                          // user_PostCount 값을 1 증가
                          final updatedPostCount = currentPostCount + 1;

                          await model.uploadPost(
                            _titleTextController.text,
                            _contentTextController.text,
                            _localSelectedValue!,
                            int.parse(_recruitTextController.text),
                            DateTime.now(),
                            'https://cdn.hankyung.com/photo/202409/01.37954272.1.jpg',
                            convertXFilesToFiles(xfileImages),
                            _addressTextController.text,
                            _detailAddressTextController.text,
                            categories[_selectedCategoryIndex!],
                            saveToDatabase(),
                            _selectedDate!,
                          );

                          // Firestore에서 user_PostCount 업데이트
                          await userDoc.update({'user_PostCount': updatedPostCount});
                        } else {
                          if (widget.post != null) {
                            await model.updatePost(
                              widget.post!.documentId,
                              _titleTextController.text,
                              _contentTextController.text,
                              _localSelectedValue!,
                              int.parse(_recruitTextController.text),
                              convertXFilesToFiles(xfileImages),
                              stringImages,
                              _addressTextController.text,
                              _detailAddressTextController.text,
                              categories[_selectedCategoryIndex!],
                              saveToDatabase(),
                              _selectedDate!,
                            );
                          }
                        }

                        // 업로드가 완료되면 다이얼로그 닫고 화면 이동
                        if (mounted) {
                          Navigator.pop(context); // 로딩 스피너 닫기
                          Navigator.pop(context, true); // 이전 화면으로 돌아가기
                        }
                      } catch (e) {
                        Navigator.pop(context); // 로딩 스피너 닫기
                        // 에러 처리 (예: 스낵바로 오류 메시지 표시)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("업로드 중 오류가 발생했습니다."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      // 필수 입력 항목이 누락되었을 때 알림
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("모든 필드를 올바르게 입력해주세요."),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    '작성완료',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
