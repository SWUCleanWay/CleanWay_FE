import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/main.dart';

class CreateReportScreen extends StatefulWidget {
  @override
  _CreateReportScreenState createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  String _selectedIssue = '';
  int _selectedIssueNumber = 0; // 이슈 번호
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _locationController = TextEditingController();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      print("Image picked: ${pickedFile.path}");  // 이미지 선택 로그
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print("No image selected.");  // 이미지 선택 실패 로그
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
          backgroundColor: _selectedIssue == issue ? Color(0xFF588100) : Colors
              .white,
          foregroundColor: _selectedIssue == issue ? Colors.white : Colors
              .black,
          shape: StadiumBorder(),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        onPressed: () {
          setState(() {
            _selectedIssue = issue;
            _selectedIssueNumber =
            issue == '쓰레기' ? 1 : issue == '전단지' ? 2 : issue == '담배꽁초' ? 3 : 4;
          });
        },
        child: Text(issue),
      ),
    );
  }

  Future<void> _uploadReport() async {
    if (_image == null || _locationController.text.isEmpty || _selectedIssue.isEmpty) {
      print('Validation failed: Some fields are empty.'); // 필드 검증 실패 로그
      return;
    }

    print('Image path: ${_image!.path}'); // 이미지 경로 로그
    String base64Image;
    try {
      base64Image = base64Encode(await _image!.readAsBytes());
      print("Base64 Image: $base64Image"); // Base64 인코딩 로그
    } catch (e) {
      print("Error encoding image: $e"); // 이미지 인코딩 에러 로그
      return;
    }

    int reportNumber = DateTime.now().millisecondsSinceEpoch;
    int userNumber = 1;
    Map<String, dynamic> requestData = {
      "cleanReportDto": {
        "reportNumber": reportNumber,
        "userNumber": userNumber,
        "keywordNumber": _selectedIssueNumber,
        "reportDate": DateTime.now().toString()
      },
      "reportSpotDto": {
        "spotNumber": 0,
        "spotLat": 37.422,
        "spotIng": -122.084,
        "spotName": _locationController.text,
        "reportNumber": reportNumber
      },
      "base64EncodedImage": base64Image
    };

    print('Request data prepared.'); // 요청 데이터 준비 완료 로그
    print('Sending Request...');
    try {
      var response = await http.post(
        Uri.parse('${dotenv.env['NGROK_URL']}/report/add'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestData),
      );
      print('Response status code: ${response.statusCode}'); // 응답 상태 코드 로그
      print('Response body: ${response.body}'); // 응답 본문 로그

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Success: Report uploaded');
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(initialCrewSelected: false)),
        );
      } else {
        print('Failed to upload report. Server responded with status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading report: $e'); // 요청 전송 에러 로그
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
              Text('사진',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              Text('위치',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: '위치 입력',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text('문제상황',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              backgroundColor: Theme
                  .of(context)
                  .colorScheme
                  .primary,
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

