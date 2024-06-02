import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '/main.dart';
import '/widgets/location_search.dart';

class CreateReportCopyScreen extends StatefulWidget {
  @override
  _CreateReportCopyScreenState createState() => _CreateReportCopyScreenState();
}

class _CreateReportCopyScreenState extends State<CreateReportCopyScreen> {
  String _selectedIssue = '';
  int _selectedIssueNumber = 0;  // 이슈 번호
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _locationController = TextEditingController();
  double? _selectedLatitude; // 선택된 위치의 위도
  double? _selectedLongitude; // 선택된 위치의 경도

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

  void _navigateAndDisplayLocationSelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LocationSearch()),
    );

    if (result != null) {
      setState(() {
        _locationController.text = result['spotName'];
        _selectedLatitude = result['spotLat'];
        _selectedLongitude = result['spotLng'];
      });
    }
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
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        onPressed: () {
          setState(() {
            _selectedIssue = issue;
            _selectedIssueNumber = issue == '쓰레기' ? 1 : issue == '전단지' ? 2 : issue == '담배꽁초' ? 3 : 4;
          });
        },
        child: Text(issue),
      ),
    );
  }

  Future<void> _uploadReport() async {
    print('Uploading report...');

    if (_image == null || _locationController.text.isEmpty || _selectedIssue.isEmpty || _selectedLatitude == null || _selectedLongitude == null) {
      print('Validation failed: Some fields are empty.');
      return;
    }

    int reportNumber = DateTime.now().millisecondsSinceEpoch;
    int userNumber = 1;  // 예제 사용자 번호
    String base64Image = base64Encode(_image!.readAsBytesSync());
    String imageFileName = 'report_image_${DateTime.now().millisecondsSinceEpoch}.png';

    Map<String, dynamic> requestData = {
      "cleanReportDto": {
        "reportNumber": reportNumber,
        "userNumber": userNumber,
        "keywordNumber": _selectedIssueNumber,
        "reportDate": DateTime.now().toString()
      },
      "reportSpotDto": {
        "spotNumber": 0,
        "spotLat": _selectedLatitude,
        "spotLng": _selectedLongitude,
        "spotName": _locationController.text,
        "reportNumber": reportNumber
      },
      "base64EncodedImage": base64Image
    };

    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['NGROK_URL']}/report/add'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestData),
      );

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
                child: _image != null ? Image.file(_image!, fit: BoxFit.cover) : Icon(Icons.camera_alt, color: Colors.grey[800]),
              ),
            ),
            SizedBox(height: 20),
            Text('위치', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () => _navigateAndDisplayLocationSelection(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: '위치 입력',
                    border: OutlineInputBorder(),
                  ),
                ),
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
