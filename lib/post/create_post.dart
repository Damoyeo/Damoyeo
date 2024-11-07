import 'dart:async';
import 'dart:io';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gomoph/models//create_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kpostal/kpostal.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final model = new CreateModel();

  ////////////////////////////////////////////////////////// firebase에 넣을 변수들, 컨트롤러들
  final _titleTextController = TextEditingController(); //제목 컨트롤러
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
  final _addressTextController = TextEditingController(); //활동장소 컨트롤러
  final _detailAddressTextController = TextEditingController(); //상세주소 컨트롤러
  final _costTextController = TextEditingController(); //예상 활동금액 컨트롤러
  String? _limitSelectedValue; //불참 횟수 드롭다운버튼 값
  final _contentTextController = TextEditingController(); //게시글 내용 컨트롤러

  @override
  void dispose() {
    // TODO: implement dispose
    _titleTextController.dispose();
    _addressTextController.dispose();
    _detailAddressTextController.dispose();
    _costTextController.dispose();
    _contentTextController.dispose();
    super.dispose();
  }

  //////////////////////////////////////////////////////////

  final ImagePicker _picker = ImagePicker();
  List<XFile?> _images = []; // 업로드된 이미지 목록

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
                                child: Image.file(
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
                border: OutlineInputBorder(),
              ),
            ),
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
            SizedBox(height: 16),
            Text('지역',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _localSelectedValue,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              hint: Text('지역을 선택해주세요.'),
              items: ['서울특별시', '부산광역시', '대구광역시']
                  .map((String value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _localSelectedValue = newValue; // 선택된 값 업데이트
                });
              },
            ),
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
                      border: OutlineInputBorder(),
                    ),
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
            SizedBox(height: 8),
            TextField(
              controller: _detailAddressTextController,
              decoration: InputDecoration(
                hintText: '상세주소',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text('모집 인원',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: '모집 인원을 입력해주세요.',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
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
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Text('불참 횟수 제한',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _limitSelectedValue,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              hint: Text('불참 횟수를 선택해주세요.'),
              items: ['1회', '2회', '3회', '무제한']
                  .map((String value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _limitSelectedValue = newValue; // 선택된 값 업데이트
                });
              },
            ),
            SizedBox(height: 16),
            Text('모집글 내용',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _contentTextController,
              decoration: InputDecoration(
                hintText: '모집글 내용을 작성해주세요.',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: double.infinity, // 화면 너비에 맞춰서 버튼을 꽉 차게 설정
                child: ElevatedButton(
                  onPressed: () async {
                    // 작성 완료 기능 추가
                    if (_localSelectedValue != null &&
                        _titleTextController.text.isNotEmpty &&
                        _contentTextController.text.isNotEmpty &&
                        _addressTextController.text.isNotEmpty &&
                        _detailAddressTextController.text.isNotEmpty &&
                        _costTextController.text.isNotEmpty &&
                        _selectedCategoryIndex != null)
                      await model.uploadPost(
                        _titleTextController.text,
                        _contentTextController.text,
                        _localSelectedValue!,
                        15,
                        DateTime.now(),
                        'https://cdn.hankyung.com/photo/202409/01.37954272.1.jpg',
                        convertXFilesToFiles(_images),
                        _addressTextController.text,
                        _detailAddressTextController.text,
                        categories[_selectedCategoryIndex!],
                        saveToDatabase(),
                      );
                    if (mounted) {
                      Navigator.pop(context);
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
