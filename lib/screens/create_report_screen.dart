import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '/main.dart';

class CreateReportScreen extends StatefulWidget {
  @override
  _CreateReportScreenState createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  String _selectedIssue = '';
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _locationController = TextEditingController();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('갤러리에서 선택'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('카메라로 촬영'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget issueButton(String issue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF588100)),
          backgroundColor: _selectedIssue == issue ? Color(0xFF588100) : Colors.white,
          foregroundColor: _selectedIssue == issue ? Colors.white : Colors.black,
          shape: StadiumBorder(),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // 버튼 내부 패딩 조절
        ),
        onPressed: () {
          setState(() {
            _selectedIssue = issue;
          });
        },
        child: Text(issue),
      ),
    );
  }

  Future<void> _uploadReport() async {
    if (_image == null || _locationController.text.isEmpty || _selectedIssue.isEmpty) {
      // 필수 정보가 누락되었을 때 처리
      return;
    }

    String base64Image = base64Encode(_image!.readAsBytesSync());

    Map<String, String> requestBody = {
      'image': base64Image,
      'location': _locationController.text,
      'issue': _selectedIssue,
      'date': DateTime.now().toString(),
    };

    try {
      final response = await http.post(
        //Uri.parse('http://your-api-url/report/add'),
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('success');
        Navigator.pop(context); // 현재 페이지 스택에서 제거
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen(initialCrewSelected: false)
          ), // 메인 화면으로 이동
        );
      } else {
        // 서버에서 오류 응답을 받았을 때 처리
        print('Failed to upload report. Server responded with status code ${response.statusCode}');
      }
    } catch (e) {
      // 네트워크 오류 등 예외 발생 시 처리
      print('Error uploading report: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('제보하기'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('사진', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            InkWell(
              onTap: () => _showPicker(context),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  border: Border.all(color: Colors.black26),
                ),
                child: _image != null
                    ? Image.file(_image!, fit: BoxFit.cover)
                    : Icon(Icons.camera_alt, color: Colors.grey[800]),
              ),
            ),
            SizedBox(height: 20),
            Text('위치', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: '위치 입력',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text('문제상황', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                issueButton('쓰레기'),
                issueButton('전단지'),
                issueButton('담배꽁초'),
                issueButton('기타'),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10.0),
        child: ElevatedButton(
          onPressed: _uploadReport,
          child: Text('등록하기', style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
