import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gomoph/models//create_model.dart';
import 'package:image_picker/image_picker.dart';

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
  final _costTextController = TextEditingController(); //예상 활동금액 컨트롤러
  String? _limitSelectedValue; //불참 횟수 드롭다운버튼 값
  final _contentTextController = TextEditingController(); //게시글 내용 컨트롤러

  @override
  void dispose() {
    // TODO: implement dispose
    _titleTextController.dispose();
    _addressTextController.dispose();
    _costTextController.dispose();
    _contentTextController.dispose();
    super.dispose();
  }
  //////////////////////////////////////////////////////////

  final ImagePicker _picker = ImagePicker();
  List<XFile?> _images = []; // 업로드된 이미지 목록

  Future<void> _pickImage(ImageSource source) async {
    if (_images.length >= 10) {
      // 이미 5개의 이미지가 있으면 알림을 표시하고 반환
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("이미지는 최대 5개까지 업로드할 수 있습니다.")),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _images.add(image);
      });
    }
  }

  List<File> convertXFilesToFiles(List<XFile?> xFiles) {
    return xFiles
        .where((xfile) => xfile != null) // null 필터링
        .map((xfile) => File(xfile!.path))
        .toList();
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
                      children: _images.map((image) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Image.file(
                            File(image!.path),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
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
                hintText: 'Tell us everything.',
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
              items: ['서울특별시', '부산광역시', '대구광역시']
                  .map((String value) =>
                  DropdownMenuItem(
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
                      hintText: 'Tell us everything.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
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
            SizedBox(height: 16),
            Text('예상 활동 금액',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _costTextController,
              decoration: InputDecoration(
                hintText: 'Tell us everything.',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Text('불참 횟수 제한',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value:_limitSelectedValue,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: ['1회', '2회', '3회', '무제한']
                  .map((String value) =>
                  DropdownMenuItem(
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
            Text('Anything else?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _contentTextController,
              decoration: InputDecoration(
                hintText: 'Tell us everything.',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: double.infinity, // 화면 너비에 맞춰서 버튼을 꽉 차게 설정
                child: ElevatedButton(
                  onPressed: () {
                    // 작성 완료 기능 추가
                    if(_localSelectedValue != null && _titleTextController.text.isNotEmpty && _contentTextController.text.isNotEmpty )
                    model.uploadPost( _titleTextController.text, _contentTextController.text, _localSelectedValue!, 15, DateTime.now(), 'https://cdn.hankyung.com/photo/202409/01.37954272.1.jpg',convertXFilesToFiles(_images));
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
